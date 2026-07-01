import 'package:flutter/material.dart';

import '../../../storage/offline_drink_order_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';
import 'cat_saved_data_button.dart';

const Color _blueSoft = Color(0xFFDDF6FF);
const Color _bluePale = Color(0xFFEFFBFF);
const Color _blueDeep = Color(0xFF2D6A8D);
const String _zaloPayMethodLabel = 'ZaloPay';

const List<String> _categories = [
  'Tất cả',
  'Cafe',
  'Trà',
  'Sinh tố',
  'Bánh ngọt',
];

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

const List<_DrinkItem> _drinks = [
  _DrinkItem(
    id: 1,
    name: 'Latte Mây Xanh',
    description: 'Latte béo nhẹ, thơm sữa, hợp buổi chiều yên tĩnh.',
    category: 'Cafe',
    price: 45000,
    icon: Icons.local_cafe_rounded,
    color: Color(0xFFDDF6FF),
  ),
  _DrinkItem(
    id: 2,
    name: 'Cappuccino PetHub',
    description: 'Cappuccino nóng, lớp foam mềm như mây.',
    category: 'Cafe',
    price: 49000,
    icon: Icons.coffee_rounded,
    color: Color(0xFFE7F7FF),
  ),
  _DrinkItem(
    id: 3,
    name: 'Trà Đào Cam Sả',
    description: 'Mát nhẹ, vị đào thơm, dễ uống.',
    category: 'Trà',
    price: 42000,
    icon: Icons.emoji_food_beverage_rounded,
    color: Color(0xFFFFF0D9),
  ),
  _DrinkItem(
    id: 4,
    name: 'Trà Sữa Pastel',
    description: 'Trà sữa ngọt vừa, topping mềm.',
    category: 'Trà',
    price: 43000,
    icon: Icons.local_drink_rounded,
    color: Color(0xFFE8F7FF),
  ),
  _DrinkItem(
    id: 5,
    name: 'Sinh Tố Dâu Mây',
    description: 'Dâu xay mịn, vị chua ngọt dịu.',
    category: 'Sinh tố',
    price: 50000,
    icon: Icons.blender_rounded,
    color: Color(0xFFFFE1EA),
  ),
  _DrinkItem(
    id: 6,
    name: 'Sinh Tố Bơ Sữa',
    description: 'Bơ béo nhẹ, thơm sữa, no bụng.',
    category: 'Sinh tố',
    price: 52000,
    icon: Icons.eco_rounded,
    color: Color(0xFFE0F7E9),
  ),
  _DrinkItem(
    id: 7,
    name: 'Cheesecake Mini',
    description: 'Bánh nhỏ mềm, hợp dùng cùng trà.',
    category: 'Bánh ngọt',
    price: 39000,
    icon: Icons.cake_rounded,
    color: Color(0xFFF0E8FF),
  ),
  _DrinkItem(
    id: 8,
    name: 'Cookie Paw',
    description: 'Cookie hình dấu chân thú cưng đáng yêu.',
    category: 'Bánh ngọt',
    price: 29000,
    icon: Icons.cookie_rounded,
    color: Color(0xFFFFE8D6),
  ),
];

class CustomerDrinkOrderScreen extends StatefulWidget {
  const CustomerDrinkOrderScreen({super.key});

  @override
  State<CustomerDrinkOrderScreen> createState() =>
      _CustomerDrinkOrderScreenState();
}

class _CustomerDrinkOrderScreenState extends State<CustomerDrinkOrderScreen> {
  String _selectedCategory = 'Tất cả';
  String _keyword = '';
  String _selectedPaymentMethod = _paymentMethods.first.label;
  final Map<int, int> _cart = {};
  List<OfflineDrinkOrder> _orderHistory = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final storedCart = await OfflineDrinkOrderStorage.loadCart();
    final history = await OfflineDrinkOrderStorage.loadOrderHistory();
    if (!mounted) return;
    setState(() {
      _cart.clear();
      _cart.addAll(storedCart);
      _orderHistory = history.reversed.take(3).toList();
    });
  }

  List<_DrinkItem> get _filteredDrinks {
    return _drinks.where((drink) {
      final matchCategory =
          _selectedCategory == 'Tất cả' || drink.category == _selectedCategory;

      final matchKeyword =
          drink.name.toLowerCase().contains(_keyword.toLowerCase()) ||
          drink.description.toLowerCase().contains(_keyword.toLowerCase());

      return matchCategory && matchKeyword;
    }).toList();
  }

  int _quantityOf(int id) {
    return _cart[id] ?? 0;
  }

  int get _totalItems {
    return _cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  int get _totalPrice {
    int total = 0;

    for (final drink in _drinks) {
      total += _quantityOf(drink.id) * drink.price;
    }

    return total;
  }

  String _money(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
  }

  String _drinkName(int id) {
    return _drinks
        .firstWhere(
          (drink) => drink.id == id,
          orElse: () => _DrinkItem(
            id: id,
            name: 'Món #$id',
            description: '',
            category: 'Khác',
            price: 0,
            icon: Icons.local_cafe_rounded,
            color: Colors.white,
          ),
        )
        .name;
  }

  void _addDrink(_DrinkItem drink) {
    setState(() {
      _cart[drink.id] = _quantityOf(drink.id) + 1;
    });
    OfflineDrinkOrderStorage.saveCart(_cart);
  }

  void _removeDrink(_DrinkItem drink) {
    final currentQuantity = _quantityOf(drink.id);

    if (currentQuantity <= 1) {
      setState(() {
        _cart.remove(drink.id);
      });
    } else {
      setState(() {
        _cart[drink.id] = currentQuantity - 1;
      });
    }
    OfflineDrinkOrderStorage.saveCart(_cart);
  }

  Future<void> _submitOrder() async {
    final submittedItems = _totalItems;
    final paymentMethod = _selectedPaymentMethod;

    if (paymentMethod == _zaloPayMethodLabel) {
      final paid = await _showZaloPayQrAndAutoConfirm();
      if (!paid) return;
    }

    final order = OfflineDrinkOrder(
      createdAt: DateTime.now(),
      items: Map.from(_cart),
      totalPrice: _totalPrice,
      paymentMethod: paymentMethod,
    );

    await OfflineDrinkOrderStorage.saveOfflineOrder(order);
    await OfflineDrinkOrderStorage.clearCart();

    if (!mounted) return;
    setState(() {
      _cart.clear();
      _orderHistory = [order, ..._orderHistory].take(3).toList();
    });

    final message = paymentMethod == _zaloPayMethodLabel
        ? 'Đã thanh toán thành công và lưu vào biểu tượng mèo.'
        : 'Đã lưu đơn gọi nước với $submittedItems món vào biểu tượng mèo.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _showZaloPayQrAndAutoConfirm() async {
    final paymentCode = 'ZLP-${DateTime.now().millisecondsSinceEpoch}';

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop(true);
      }
    });

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quét mã ZaloPay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DemoQrCode(data: paymentCode),
              const SizedBox(height: 14),
              Text(
                _money(_totalPrice),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          actions: [
            TextButton.icon(
              onPressed: null,
              icon: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: Text('Đang xác nhận'),
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
        title: const Text('Gọi nước trước'),
        backgroundColor: _bluePale,
        foregroundColor: AppColors.textDark,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CatSavedDataButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _DrinkHeader(),

                    const SizedBox(height: 20),

                    if (_orderHistory.isNotEmpty) ...[
                      SectionTitle(
                        title: 'Lịch sử đặt nước',
                        actionText: '${_orderHistory.length} đơn',
                      ),
                      const SizedBox(height: 12),
                      _DrinkOrderHistory(
                        orders: _orderHistory,
                        money: _money,
                        drinkName: _drinkName,
                      ),
                      const SizedBox(height: 22),
                    ],

                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _keyword = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tìm cafe, trà sữa, sinh tố...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _blueDeep,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const SectionTitle(title: 'Danh mục món'),

                    const SizedBox(height: 12),

                    _CategorySelector(
                      selectedCategory: _selectedCategory,
                      onSelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    SectionTitle(
                      title: 'Menu hôm nay',
                      actionText: '${_filteredDrinks.length} món',
                    ),

                    const SizedBox(height: 12),

                    GridView.builder(
                      itemCount: _filteredDrinks.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 238,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final drink = _filteredDrinks[index];

                        return _DrinkCard(
                          drink: drink,
                          quantity: _quantityOf(drink.id),
                          priceText: _money(drink.price),
                          onAdd: () => _addDrink(drink),
                          onRemove: () => _removeDrink(drink),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    const SectionTitle(title: 'Thanh toán'),

                    const SizedBox(height: 12),

                    _PaymentSelector(
                      methods: _paymentMethods,
                      selectedMethod: _selectedPaymentMethod,
                      onSelected: (method) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            _CartBottomBar(
              totalItems: _totalItems,
              totalPrice: _money(_totalPrice),
              paymentMethod: _selectedPaymentMethod,
              onSubmit: _totalItems == 0 ? null : _submitOrder,
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoQrCode extends StatelessWidget {
  final String data;

  const _DemoQrCode({required this.data});

  @override
  Widget build(BuildContext context) {
    const size = 17;

    return Container(
      width: 196,
      height: 196,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _blueSoft, width: 2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: size * size,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ size;
          final col = index % size;
          final isDark = _isDarkCell(row, col, size);

          return Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isDark ? _blueDeep : Colors.white,
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        },
      ),
    );
  }

  bool _isDarkCell(int row, int col, int size) {
    final inTopLeft = row < 5 && col < 5;
    final inTopRight = row < 5 && col >= size - 5;
    final inBottomLeft = row >= size - 5 && col < 5;

    if (inTopLeft || inTopRight || inBottomLeft) {
      final localRow = row % (size - 5);
      final localCol = col % (size - 5);
      return localRow == 0 ||
          localRow == 4 ||
          localCol == 0 ||
          localCol == 4 ||
          (localRow == 2 && localCol == 2);
    }

    final seed = data.codeUnitAt((row + col) % data.length);
    return (row * 31 + col * 17 + seed) % 5 < 2;
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
          colors: [_blueSoft, Color(0xFFE9FAFF), Colors.white],
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
              color: Colors.white.withValues(alpha: 0.85),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đặt nước trước',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: _blueDeep),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chọn món trước để khi ghé PetHub, bàn và nước đều sẵn sàng.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategorySelector({
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == selectedCategory;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _blueDeep : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? _blueDeep : _blueSoft),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : _blueDeep,
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
  final String Function(int id) drinkName;

  const _DrinkOrderHistory({
    required this.orders,
    required this.money,
    required this.drinkName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: orders.map((order) {
        final totalItems = order.items.values.fold<int>(
          0,
          (sum, quantity) => sum + quantity,
        );
        final itemText = order.items.entries
            .map((entry) => '${drinkName(entry.key)} x${entry.value}')
            .join(', ');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: _blueSoft,
                  child: Icon(Icons.receipt_long_rounded, color: _blueDeep),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalItems món • ${money(order.totalPrice)}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.paymentMethod,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _blueDeep,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _bluePale,
                    borderRadius: BorderRadius.circular(99),
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
        final isSelected = method.label == selectedMethod;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            color: isSelected ? _blueSoft : Colors.white,
            padding: const EdgeInsets.all(14),
            onTap: () => onSelected(method.label),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isSelected ? Colors.white : _bluePale,
                  child: Icon(method.icon, color: _blueDeep),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.label,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        method.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSoft,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? _blueDeep : AppColors.textSoft,
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
  final _DrinkItem drink;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                child: Icon(drink.icon, color: _blueDeep),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(99),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            drink.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.3),
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Thêm'),
              ),
            )
          else
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
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
                          fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: totalItems == 0
                ? const Color(0xFFE5E0DC)
                : _blueSoft,
            child: const Icon(Icons.shopping_bag_rounded, color: _blueDeep),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalItems == 0 ? 'Chưa chọn món' : '$totalItems món đã chọn',
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w600,
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
              disabledBackgroundColor: const Color(0xFFE5E0DC),
              disabledForegroundColor: AppColors.textSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

class _DrinkItem {
  final int id;
  final String name;
  final String description;
  final String category;
  final int price;
  final IconData icon;
  final Color color;

  const _DrinkItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
  });
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
