import 'package:flutter/material.dart';

import '../../../../models/menu_item_data.dart';
import '../../../../services/cloudinary_upload_service.dart';
import '../../../../services/menu_repository.dart';
import '../../../../theme/app_colors.dart';

class AdminManageMenuScreen extends StatefulWidget {
  const AdminManageMenuScreen({super.key});

  @override
  State<AdminManageMenuScreen> createState() =>
      _AdminManageMenuScreenState();
}

class _AdminManageMenuScreenState
    extends State<AdminManageMenuScreen> {
  late Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    _seedFuture = MenuRepository.seedDefaultMenuIfNeeded();
  }

  String formatCurrency(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
    );
  }

  void _retrySeed() {
    setState(() {
      _seedFuture =
          MenuRepository.seedDefaultMenuIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Quản lý thực đơn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<void>(
        future: _seedFuture,
        builder: (context, seedSnapshot) {
          if (seedSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (seedSnapshot.hasError) {
            return _SeedErrorView(
              message:
              'Không thể khởi tạo thực đơn mặc định.\n'
                  '${seedSnapshot.error}',
              onRetry: _retrySeed,
            );
          }

          return StreamBuilder<List<MenuItemData>>(
            stream: MenuRepository.watchAllMenuItems(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Không tải được thực đơn.\n'
                        '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final menuItems = snapshot.data!;
              final categories =
              MenuRepository.categoriesFrom(
                menuItems,
                includeAll: false,
              );

              if (menuItems.isEmpty) {
                return const Center(
                  child: Text('Chưa có món trong thực đơn.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () => _showMenuForm(
                        item: item,
                        categories: categories,
                      ),
                      leading: _MenuAvatar(item: item),
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${formatCurrency(item.price)}đ'
                            ' • ${item.category}'
                            '\n${item.sourceLabel}'
                            ' • ${item.isActive ? 'Đang bán' : 'Đang ẩn'}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: item.isActive
                                ? 'Ẩn khỏi khách hàng'
                                : 'Hiện cho khách hàng',
                            onPressed: () {
                              MenuRepository.setItemActive(
                                itemId: item.id,
                                isActive: !item.isActive,
                              );
                            },
                            icon: Icon(
                              item.isActive
                                  ? Icons.visibility_rounded
                                  : Icons
                                  .visibility_off_rounded,
                              color: item.isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sửa món',
                            onPressed: () => _showMenuForm(
                              item: item,
                              categories: categories,
                            ),
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Xóa món',
                            onPressed: () =>
                                _confirmDelete(item),
                            icon: const Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<List<MenuItemData>>(
        stream: MenuRepository.watchAllMenuItems(),
        builder: (context, snapshot) {
          final categories =
          MenuRepository.categoriesFrom(
            snapshot.data ?? const <MenuItemData>[],
            includeAll: false,
          );

          return FloatingActionButton.extended(
            onPressed: () => _showMenuForm(
              categories: categories,
            ),
            label: const Text('Thêm món mới'),
            icon: const Icon(Icons.add),
            backgroundColor: AppColors.primary,
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(MenuItemData item) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa món'),
          content: Text(
            'Xóa "${item.name}" khỏi thực đơn?\n\n'
                'Món sẽ biến mất ở cả Admin và khách hàng.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (accepted != true) {
      return;
    }

    try {
      await MenuRepository.deleteItem(item.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${item.name}.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không xóa được món: $error'),
        ),
      );
    }
  }

  void _showMenuForm({
    MenuItemData? item,
    required List<String> categories,
  }) {
    const customCategoryValue = '__custom_category__';

    final categoryOptions = <String>{
      ...categories.where(
            (category) => category.trim().isNotEmpty,
      ),
    }.toList();

    if (categoryOptions.isEmpty) {
      categoryOptions.addAll([
        'Cafe',
        'Trà',
        'Sinh tố',
        'Bánh ngọt',
        'Khác',
      ]);
    }

    final nameController = TextEditingController(
      text: item?.name ?? '',
    );

    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );

    final priceController = TextEditingController(
      text: item == null
          ? ''
          : formatCurrency(item.price),
    );

    final newCategoryController =
    TextEditingController();

    String selectedCategory;

    if (item != null &&
        categoryOptions.contains(item.category)) {
      selectedCategory = item.category;
    } else {
      selectedCategory = categoryOptions.first;
    }

    String currentImageUrl = item?.imageUrl ?? '';
    bool isUploading = false;
    bool isSaving = false;
    bool isActive = item?.isActive ?? true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> uploadImage() async {
              try {
                final image =
                await CloudinaryUploadService
                    .pickImageFromGallery();

                if (image == null) {
                  return;
                }

                setDialogState(() {
                  isUploading = true;
                });

                final result =
                await CloudinaryUploadService
                    .uploadImageFile(image);

                setDialogState(() {
                  currentImageUrl =
                      CloudinaryUploadService
                          .optimizedImageUrl(
                        result.imageUrl,
                      );

                  isUploading = false;
                });
              } catch (error) {
                setDialogState(() {
                  isUploading = false;
                });

                if (!dialogContext.mounted) {
                  return;
                }

                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Không tải được ảnh: $error',
                    ),
                  ),
                );
              }
            }

            Future<void> saveItem() async {
              final name = nameController.text.trim();

              final category = selectedCategory ==
                  customCategoryValue
                  ? newCategoryController.text.trim()
                  : selectedCategory.trim();

              final rawPrice =
              priceController.text.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );

              final price = int.tryParse(rawPrice) ?? 0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(
                  const SnackBar(
                    content:
                    Text('Vui lòng nhập tên món.'),
                  ),
                );
                return;
              }

              if (category.isEmpty) {
                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(
                  const SnackBar(
                    content:
                    Text('Vui lòng nhập danh mục.'),
                  ),
                );
                return;
              }

              if (price <= 0) {
                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(
                  const SnackBar(
                    content:
                    Text('Giá món phải lớn hơn 0.'),
                  ),
                );
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                if (item == null) {
                  await MenuRepository.addItem(
                    name: name,
                    description:
                    descriptionController.text,
                    category: category,
                    price: price,
                    imageUrl: currentImageUrl,
                    isActive: isActive,
                  );
                } else {
                  await MenuRepository.updateItem(
                    itemId: item.id,
                    name: name,
                    description:
                    descriptionController.text,
                    category: category,
                    price: price,
                    imageUrl: currentImageUrl,
                    iconKey: item.iconKey,
                    colorValue: item.colorValue,
                    isActive: isActive,
                  );
                }

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);
              } catch (error) {
                setDialogState(() {
                  isSaving = false;
                });

                if (!dialogContext.mounted) {
                  return;
                }

                ScaffoldMessenger.of(dialogContext)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Không lưu được món: $error',
                    ),
                  ),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                item == null
                    ? 'Thêm món mới'
                    : 'Sửa món',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: isUploading || isSaving
                          ? null
                          : uploadImage,
                      child: Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: isUploading
                            ? const Center(
                          child:
                          CircularProgressIndicator(),
                        )
                            : currentImageUrl.isNotEmpty
                            ? ClipRRect(
                          borderRadius:
                          BorderRadius
                              .circular(12),
                          child: Image.network(
                            currentImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (
                                context,
                                error,
                                stackTrace,
                                ) {
                              return const Icon(
                                Icons
                                    .broken_image_rounded,
                              );
                            },
                          ),
                        )
                            : const Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameController,
                      decoration:
                      const InputDecoration(
                        labelText: 'Tên món',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      minLines: 2,
                      maxLines: 3,
                      decoration:
                      const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType:
                      TextInputType.number,
                      decoration:
                      const InputDecoration(
                        labelText: 'Giá tiền',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: [
                        ...categoryOptions.map(
                              (category) =>
                              DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                        ),
                        const DropdownMenuItem(
                          value: customCategoryValue,
                          child:
                          Text('Thêm danh mục mới'),
                        ),
                      ],
                      onChanged: isSaving
                          ? null
                          : (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedCategory =
                              value;
                        });
                      },
                      decoration:
                      const InputDecoration(
                        labelText: 'Danh mục',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (selectedCategory ==
                        customCategoryValue) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller:
                        newCategoryController,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Tên danh mục mới',
                          border:
                          OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title:
                      const Text('Hiển thị cho khách'),
                      subtitle: Text(
                        isActive
                            ? 'Khách hàng đang thấy món này'
                            : 'Món đang bị ẩn khỏi khách hàng',
                      ),
                      value: isActive,
                      onChanged: isSaving
                          ? null
                          : (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isUploading || isSaving
                      ? null
                      : saveItem,
                  child: isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MenuAvatar extends StatelessWidget {
  final MenuItemData item;

  const _MenuAvatar({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: item.color,
      child: item.imageUrl.isEmpty
          ? Icon(
        item.icon,
        color: AppColors.primary,
      )
          : ClipOval(
        child: Image.network(
          item.imageUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return Icon(
              item.icon,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }
}

class _SeedErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SeedErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}