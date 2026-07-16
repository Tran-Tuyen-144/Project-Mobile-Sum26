import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/menu_item_data.dart';
import '../../../services/admin_notification_service.dart';
import '../../../services/crm_service.dart';
import '../../../services/menu_repository.dart';
import '../../../services/order_revenue_service.dart';
import '../../../storage/offline_drink_order_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'cat_saved_data_button.dart';

const Color _blueSoft = Color(0xFFDDF6FF);
const Color _bluePale = Color(0xFFEFFBFF);
const Color _blueDeep = Color(0xFF2D6A8D);

const String _zaloPayMethodLabel = 'ZaloPay';

const List<_PaymentMethod> _paymentMethods = [
  _PaymentMethod(
    label: _zaloPayMethodLabel,
    description: 'Quét mã QR demo và tự xác nhận đã thanh toán.',
    icon: Icons.wallet_rounded,
  ),
  _PaymentMethod(
    label: 'Thanh toán tại quầy',
    description: 'Trả tiền khi nhận nước tại PetHub.',
    icon: Icons.storefront_rounded,
  ),
];

class CustomerDrinkOrderScreen extends StatefulWidget {
  const CustomerDrinkOrderScreen({super.key});

  @override
  State<CustomerDrinkOrderScreen> createState() =>
      _CustomerDrinkOrderScreenState();
}

class _CustomerDrinkOrderScreenState
    extends State<CustomerDrinkOrderScreen> {
  String _selectedCategory = 'Tất cả';
  String _keyword = '';
  String _selectedPaymentMethod = _paymentMethods.first.label;

  final Map<String, int> _cart = {};
  List<OfflineDrinkOrder> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final storedCart = await OfflineDrinkOrderStorage.loadCart();
    final history = await OfflineDrinkOrderStorage.loadOrderHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      _cart
        ..clear()
        ..addAll(storedCart);

      _orderHistory = history.reversed.take(10).toList();
    });
  }

  List<MenuItemData> _filteredDrinks(
      List<MenuItemData> drinks,
      String selectedCategory,
      ) {
    final normalizedKeyword = _keyword.trim().toLowerCase();

    return drinks.where((drink) {
      final matchesCategory =
          selectedCategory == 'Tất cả' ||
              drink.category == selectedCategory;

      final matchesKeyword =
          normalizedKeyword.isEmpty ||
              drink.name.toLowerCase().contains(normalizedKeyword) ||
              drink.description.toLowerCase().contains(normalizedKeyword) ||
              drink.category.toLowerCase().contains(normalizedKeyword);

      return matchesCategory && matchesKeyword;
    }).toList();
  }

  int _quantityOf(String itemId) {
    return _cart[itemId] ?? 0;
  }

  int get _totalItems {
    return _cart.values.fold<int>(
      0,
          (sum, quantity) => sum + quantity,
    );
  }

  int _totalPrice(List<MenuItemData> drinks) {
    final menuById = {
      for (final drink in drinks) drink.id: drink,
    };

    var total = 0;

    for (final entry in _cart.entries) {
      final drink = menuById[entry.key];

      if (drink == null) {
        continue;
      }

      total += drink.price * entry.value;
    }

    return total;
  }

  String _money(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );

    return '${formatted}đ';
  }

  void _addDrink(MenuItemData drink) {
    setState(() {
      _cart[drink.id] = _quantityOf(drink.id) + 1;
    });

    OfflineDrinkOrderStorage.saveCart(_cart);
  }

  void _removeDrink(MenuItemData drink) {
    final currentQuantity = _quantityOf(drink.id);

    setState(() {
      if (currentQuantity <= 1) {
        _cart.remove(drink.id);
      } else {
        _cart[drink.id] = currentQuantity - 1;
      }
    });

    OfflineDrinkOrderStorage.saveCart(_cart);
  }

  Future<void> _submitOrder(
      List<MenuItemData> menuItems,
      ) async {
    final menuById = {
      for (final item in menuItems) item.id: item,
    };

    final missingItemIds = _cart.keys
        .where((itemId) => !menuById.containsKey(itemId))
        .toList();

    if (missingItemIds.isNotEmpty) {
      setState(() {
        for (final itemId in missingItemIds) {
          _cart.remove(itemId);
        }
      });

      await OfflineDrinkOrderStorage.saveCart(_cart);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Một số món trong giỏ đã bị Admin xóa hoặc ngừng bán.',
          ),
        ),
      );

      return;
    }

    final submittedItems = _totalItems;
    final paymentMethod = _selectedPaymentMethod;
    final totalPrice = _totalPrice(menuItems);

    if (submittedItems <= 0 || totalPrice <= 0) {
      return;
    }

    if (paymentMethod == _zaloPayMethodLabel) {
      final paid = await _showZaloPayQrAndAutoConfirm(
        totalPrice,
      );

      if (!paid) {
        return;
      }
    }

    final itemDetails =
    <String, OfflineDrinkOrderItemSnapshot>{};

    for (final entry in _cart.entries) {
      final drink = menuById[entry.key];

      if (drink == null) {
        continue;
      }

      itemDetails[entry.key] =
          OfflineDrinkOrderItemSnapshot(
            itemId: drink.id,
            name: drink.name,
            category: drink.category,
            unitPrice: drink.price,
            quantity: entry.value,
            imageUrl: drink.imageUrl,
          );
    }

    final order = OfflineDrinkOrder(
      createdAt: DateTime.now(),
      items: Map<String, int>.from(_cart),
      itemDetails: itemDetails,
      totalPrice: totalPrice,
      paymentMethod: paymentMethod,
    );

    final firestoreItems = itemDetails.values.map((item) {
      return <String, dynamic>{
        'itemId': item.itemId,
        'name': item.name,
        'category': item.category,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'subtotal': item.unitPrice * item.quantity,
        'imageUrl': item.imageUrl,
      };
    }).toList();

    try {
      await OrderRevenueService.createCustomerCafeOrder(
        items: firestoreItems,
        totalAmount: order.totalPrice,
        paymentMethod: paymentMethod,
        isPaid: paymentMethod == _zaloPayMethodLabel,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không đồng bộ được đơn hàng: '
                '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );

      return;
    }

    await OfflineDrinkOrderStorage.saveOfflineOrder(order);
    await OfflineDrinkOrderStorage.clearCart();

    await AdminNotificationService.create(
      title: 'Đơn gọi nước mới',
      body:
      '$submittedItems món • '
          '${_money(order.totalPrice)} • '
          '$paymentMethod',
      type: 'drink_order',
    );

    final customerId = FirebaseAuth.instance.currentUser?.uid;

    if (customerId != null) {
      try {
        await CrmService.addPoints(
          customerId: customerId,
          totalAmount: order.totalPrice,
        );
      } catch (_) {
        // Lỗi tích điểm không làm gián đoạn đơn hàng.
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _cart.clear();

      _orderHistory = [
        order,
        ..._orderHistory,
      ].take(10).toList();
    });

    final message = paymentMethod == _zaloPayMethodLabel
        ? 'Đã thanh toán và đồng bộ doanh thu với Admin.'
        : 'Đã gửi đơn đến Admin. '
        'Doanh thu sẽ được ghi nhận khi Admin xác nhận thanh toán.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _showZaloPayQrAndAutoConfirm(
      int totalPrice,
      ) async {
    final paymentCode =
        'ZLP-${DateTime.now().millisecondsSinceEpoch}';

    Future<void>.delayed(
      const Duration(seconds: 15),
          () {
        if (!mounted) {
          return;
        }

        final navigator = Navigator.of(context);

        if (navigator.canPop()) {
          navigator.pop(true);
        }
      },
    );

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quét mã ZaloPay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DemoQrCode(data: paymentCode),
              const SizedBox(height: 14),
              Text(
                _money(totalPrice),
                style: const TextStyle(
                  color: _blueDeep,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paymentCode,
                textAlign: TextAlign.center,
                style: Theme.of(
                  dialogContext,
                ).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Demo sẽ tự chuyển sang đã thanh toán sau vài giây.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: const [
            TextButton(
              onPressed: null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Đang xác nhận'),
                ],
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bluePale,
      appBar: AppBar(
        title: const Text('Gọi nước đi mà'),
        backgroundColor: _bluePale,
        foregroundColor: AppColors.textDark,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CatSavedDataButton(),
          ),
        ],
      ),
      body: StreamBuilder<List<MenuItemData>>(
        stream: MenuRepository.watchCustomerMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không tải được thực đơn.\n'
                      '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final menuItems = snapshot.data!;

          final categories = MenuRepository.categoriesFrom(
            menuItems,
          );

          final effectiveCategory =
          categories.contains(_selectedCategory)
              ? _selectedCategory
              : 'Tất cả';

          final filteredDrinks = _filteredDrinks(
            menuItems,
            effectiveCategory,
          );

          final totalPrice = _totalPrice(menuItems);

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const _DrinkHeader(),
                        const SizedBox(height: 20),

                        if (_orderHistory.isNotEmpty) ...[
                          SectionTitle(
                            title: 'Lịch sử đặt nước',
                            actionText:
                            '${_orderHistory.length} đơn',
                          ),
                          const SizedBox(height: 12),
                          _DrinkOrderHistory(
                            orders: _orderHistory,
                            money: _money,
                          ),
                          const SizedBox(height: 22),
                        ],

                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _keyword = value;
                            });
                          },
                          decoration:
                          const InputDecoration(
                            hintText:
                            'Tìm cafe, trà sữa, sinh tố...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: _blueDeep,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const SectionTitle(
                          title: 'Danh mục món',
                        ),

                        const SizedBox(height: 12),

                        _CategorySelector(
                          categories: categories,
                          selectedCategory:
                          effectiveCategory,
                          onSelected: (category) {
                            setState(() {
                              _selectedCategory =
                                  category;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        SectionTitle(
                          title: 'Menu hôm nay',
                          actionText:
                          '${filteredDrinks.length} món',
                        ),

                        const SizedBox(height: 12),

                        if (filteredDrinks.isEmpty)
                          const SoftCard(
                            color: Colors.white,
                            child: Text(
                              'Không có món phù hợp.',
                            ),
                          )
                        else
                          GridView.builder(
                            itemCount:
                            filteredDrinks.length,
                            shrinkWrap: true,
                            physics:
                            const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 238,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (
                                context,
                                index,
                                ) {
                              final drink =
                              filteredDrinks[index];

                              return _DrinkCard(
                                drink: drink,
                                quantity: _quantityOf(
                                  drink.id,
                                ),
                                priceText: _money(
                                  drink.price,
                                ),
                                onAdd: () =>
                                    _addDrink(drink),
                                onRemove: () =>
                                    _removeDrink(drink),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        const SectionTitle(
                          title: 'Thanh toán',
                        ),

                        const SizedBox(height: 12),

                        _PaymentSelector(
                          methods: _paymentMethods,
                          selectedMethod:
                          _selectedPaymentMethod,
                          onSelected: (method) {
                            setState(() {
                              _selectedPaymentMethod =
                                  method;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                _CartBottomBar(
                  totalItems: _totalItems,
                  totalPrice: _money(totalPrice),
                  paymentMethod:
                  _selectedPaymentMethod,
                  onSubmit: _totalItems == 0
                      ? null
                      : () => _submitOrder(
                    menuItems,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DemoQrCode extends StatelessWidget {
  final String data;

  const _DemoQrCode({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const size = 17;

    return Container(
      width: 196,
      height: 196,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _blueSoft,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: size * size,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final column = index % size;

          final isDark = _isDarkCell(
            row,
            column,
            size,
          );

          return Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isDark
                  ? _blueDeep
                  : Colors.white,
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        },
      ),
    );
  }

  bool _isDarkCell(
      int row,
      int column,
      int size,
      ) {
    final inTopLeft = row < 5 && column < 5;

    final inTopRight =
        row < 5 && column >= size - 5;

    final inBottomLeft =
        row >= size - 5 && column < 5;

    if (inTopLeft || inTopRight || inBottomLeft) {
      final localRow = row % (size - 5);
      final localColumn = column % (size - 5);

      return localRow == 0 ||
          localRow == 4 ||
          localColumn == 0 ||
          localColumn == 4 ||
          (localRow == 2 && localColumn == 2);
    }

    final seed = data.codeUnitAt(
      (row + column) % data.length,
    );

    return (row * 31 + column * 17 + seed) % 5 < 2;
  }
}

class _DrinkHeader extends StatelessWidget {
  const _DrinkHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            _blueSoft,
            Color(0xFFE9FAFF),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.85,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: _blueDeep,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn nước lẹ lên',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: _blueDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn món trước để khi ghé PetHub, '
                      'bàn và nước đều sẵn sàng.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    height: 1.4,
                    color: AppColors.textSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) =>
        const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];

          final isSelected =
              category == selectedCategory;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? _blueDeep
                    : Colors.white,
                borderRadius:
                BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? _blueDeep
                      : _blueSoft,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : _blueDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DrinkOrderHistory extends StatelessWidget {
  final List<OfflineDrinkOrder> orders;
  final String Function(int value) money;

  const _DrinkOrderHistory({
    required this.orders,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: orders.map((order) {
        final totalItems =
        order.items.values.fold<int>(
          0,
              (sum, quantity) => sum + quantity,
        );

        final itemText = order.items.entries
            .map(
              (entry) =>
          '${order.itemName(entry.key)} '
              'x${entry.value}',
        )
            .join(', ');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: Colors.white,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: _blueSoft,
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: _blueDeep,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalItems món • '
                            '${money(order.totalPrice)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemText,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.paymentMethod,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: _blueDeep,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _bluePale,
                    borderRadius:
                    BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'Đã lưu',
                    style: TextStyle(
                      color: _blueDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  final List<_PaymentMethod> methods;
  final String selectedMethod;
  final ValueChanged<String> onSelected;

  const _PaymentSelector({
    required this.methods,
    required this.selectedMethod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: methods.map((method) {
        final isSelected =
            method.label == selectedMethod;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: isSelected
                ? _blueSoft
                : Colors.white,
            padding: const EdgeInsets.all(14),
            onTap: () =>
                onSelected(method.label),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected
                      ? Colors.white
                      : _bluePale,
                  child: Icon(
                    method.icon,
                    color: _blueDeep,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.label,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        method.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color:
                          AppColors.textSoft,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isSelected
                      ? Icons
                      .radio_button_checked_rounded
                      : Icons
                      .radio_button_off_rounded,
                  color: isSelected
                      ? _blueDeep
                      : AppColors.textSoft,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DrinkCard extends StatelessWidget {
  final MenuItemData drink;
  final int quantity;
  final String priceText;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _DrinkCard({
    required this.drink,
    required this.quantity,
    required this.priceText,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: drink.color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                Colors.white.withValues(
                  alpha: 0.85,
                ),
                child: drink.imageUrl.isEmpty
                    ? Icon(
                  drink.icon,
                  color: _blueDeep,
                )
                    : ClipOval(
                  child: Image.network(
                    drink.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Icon(
                        drink.icon,
                        color: _blueDeep,
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  borderRadius:
                  BorderRadius.circular(99),
                ),
                child: Text(
                  drink.category,
                  style: const TextStyle(
                    color: _blueDeep,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            drink.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            drink.description.isEmpty
                ? 'Món ngon tại PetHub.'
                : drink.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            priceText,
            style: const TextStyle(
              color: _blueDeep,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (quantity == 0)
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blueDeep,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Thêm'),
              ),
            )
          else
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.85,
                ),
                borderRadius:
                BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.remove_rounded,
                      size: 18,
                      color: _blueDeep,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: _blueDeep,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: _blueDeep,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  final int totalItems;
  final String totalPrice;
  final String paymentMethod;
  final VoidCallback? onSubmit;

  const _CartBottomBar({
    required this.totalItems,
    required this.totalPrice,
    required this.paymentMethod,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: totalItems == 0
                ? const Color(0xFFE5E0DC)
                : _blueSoft,
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: _blueDeep,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  totalItems == 0
                      ? 'Chưa chọn món'
                      : '$totalItems món đã chọn',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  totalPrice,
                  style: const TextStyle(
                    color: _blueDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  paymentMethod,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: AppColors.textSoft,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blueDeep,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              const Color(0xFFE5E0DC),
              disabledForegroundColor:
              AppColors.textSoft,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(18),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final String label;
  final String description;
  final IconData icon;

  const _PaymentMethod({
    required this.label,
    required this.description,
    required this.icon,
  });
}