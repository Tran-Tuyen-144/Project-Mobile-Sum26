import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/section_title.dart';
import '../../../widgets/soft_card.dart';

const Color _blueMain = Color(0xFF8ECAE6);
const Color _blueSoft = Color(0xFFDDF6FF);
const Color _bluePale = Color(0xFFEFFBFF);
const Color _blueDeep = Color(0xFF2D6A8D);
const Color _blueCard = Color(0xFFF4FCFF);

const List<String> _categories = [
  'Tất cả',
  'Cafe',
  'Trà',
  'Sinh tố',
  'Bánh ngọt',
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
  final Map<int, int> _cart = {};

  List<_DrinkItem> get _filteredDrinks {
    return _drinks.where((drink) {
      final matchCategory =
          _selectedCategory == 'Tất cả' || drink.category == _selectedCategory;

      final matchKeyword = drink.name.toLowerCase().contains(
        _keyword.toLowerCase(),
      ) ||
          drink.description.toLowerCase().contains(
            _keyword.toLowerCase(),
          );

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
    return '${value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    )}đ';
  }

  void _addDrink(_DrinkItem drink) {
    setState(() {
      _cart[drink.id] = _quantityOf(drink.id) + 1;
    });
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
  }

  void _submitOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã thêm $_totalItems món vào đơn gọi nước.',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bluePale,
      appBar: AppBar(
        title: const Text('Gọi nước trước'),
        backgroundColor: _bluePale,
        foregroundColor: AppColors.textDark,
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
                  ],
                ),
              ),
            ),

            _CartBottomBar(
              totalItems: _totalItems,
              totalPrice: _money(_totalPrice),
              onSubmit: _totalItems == 0 ? null : _submitOrder,
            ),
          ],
        ),
      ),
    );
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
              color: Colors.white.withOpacity(0.85),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _blueDeep,
                  ),
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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
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
                border: Border.all(
                  color: isSelected ? _blueDeep : _blueSoft,
                ),
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
                backgroundColor: Colors.white.withOpacity(0.85),
                child: Icon(
                  drink.icon,
                  color: _blueDeep,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                color: Colors.white.withOpacity(0.85),
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
  final VoidCallback? onSubmit;

  const _CartBottomBar({
    required this.totalItems,
    required this.totalPrice,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: totalItems == 0 ? const Color(0xFFE5E0DC) : _blueSoft,
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: _blueDeep,
            ),
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