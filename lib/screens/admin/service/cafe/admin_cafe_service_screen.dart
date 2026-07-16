import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../theme/app_colors.dart';
import 'checkout_screen.dart';
import 'customer_cafe_orders_panel.dart';

const Color _blueSoft = Color(0xFFDDF6FF);
const Color _bluePale = Color(0xFFEFFBFF);
const Color _blueDeep = Color(0xFF2D6A8D);

class _DrinkItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final int price;
  final IconData icon;
  final Color color;
  final String? imageUrl;

  const _DrinkItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}

const List<_DrinkItem> _mockDrinks = [
  _DrinkItem(
    id: 'mock_1',
    name: 'Latte Mây Xanh',
    description: 'Latte béo nhẹ, thơm sữa, hợp buổi chiều yên tĩnh.',
    category: 'Cafe',
    price: 45000,
    icon: Icons.local_cafe_rounded,
    color: Color(0xFFDDF6FF),
  ),
  _DrinkItem(
    id: 'mock_2',
    name: 'Cappuccino PetHub',
    description: 'Cappuccino nóng, lớp foam mềm như mây.',
    category: 'Cafe',
    price: 49000,
    icon: Icons.coffee_rounded,
    color: Color(0xFFE7F7FF),
  ),
  _DrinkItem(
    id: 'mock_3',
    name: 'Trà Đào Cam Sả',
    description: 'Mát nhẹ, vị đào thơm, dễ uống.',
    category: 'Trà',
    price: 42000,
    icon: Icons.emoji_food_beverage_rounded,
    color: Color(0xFFFFF0D9),
  ),
  _DrinkItem(
    id: 'mock_4',
    name: 'Trà Sữa Pastel',
    description: 'Trà sữa ngọt vừa, topping mềm.',
    category: 'Trà',
    price: 43000,
    icon: Icons.local_drink_rounded,
    color: Color(0xFFE8F7FF),
  ),
];

class AdminCafeServiceScreen extends StatefulWidget {
  const AdminCafeServiceScreen({super.key});

  @override
  State<AdminCafeServiceScreen> createState() => _AdminCafeServiceScreenState();
}

class _AdminCafeServiceScreenState extends State<AdminCafeServiceScreen> {
  String _selectedCategory = 'Tất cả';
  String _keyword = '';

  final Map<String, int> _cart = {};
  final Map<String, _DrinkItem> _cartItems = {};

  int _quantityOf(String id) => _cart[id] ?? 0;

  int get _totalItems {
    return _cart.values.fold<int>(0, (total, quantity) => total + quantity);
  }

  String _money(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
  }

  void _addDrink(_DrinkItem drink) {
    setState(() {
      _cartItems[drink.id] = drink;
      _cart[drink.id] = _quantityOf(drink.id) + 1;
    });
  }

  void _removeDrink(String id) {
    final currentQuantity = _quantityOf(id);
    if (currentQuantity <= 1) {
      setState(() {
        _cart.remove(id);
        _cartItems.remove(id);
      });
    } else {
      setState(() => _cart[id] = currentQuantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bluePale,
      appBar: AppBar(
        title: const Text('POS Gọi nước'),
        backgroundColor: _bluePale,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menu_items').snapshots(),
        builder: (context, snapshot) {
          List<_DrinkItem> allDrinks = List.from(_mockDrinks);

          if (snapshot.hasData) {
            final firebaseDrinks = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _DrinkItem(
                id: doc.id,
                name: data['name'] ?? '',
                description: 'Món nước từ menu',
                category: data['category'] ?? 'Khác',
                price: (data['price'] ?? 0) as int,
                icon: Icons.star_rounded,
                color: Colors.white,
                imageUrl: data['image'],
              );
            }).toList();
            allDrinks.addAll(firebaseDrinks);
          }

          final Set<String> uniqueCategories = {'Tất cả'};
          for (var drink in allDrinks) {
            uniqueCategories.add(drink.category);
          }
          final List<String> dynamicCategories = uniqueCategories.toList();

          final filteredDrinks = allDrinks.where((drink) {
            final matchCategory =
                _selectedCategory == 'Tất cả' ||
                drink.category == _selectedCategory;
            final matchKeyword = drink.name.toLowerCase().contains(
              _keyword.toLowerCase(),
            );
            return matchCategory && matchKeyword;
          }).toList();

          int currentTotalPrice = 0;
          for (var drink in allDrinks) {
            currentTotalPrice += _quantityOf(drink.id) * drink.price;
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomerCafeOrdersPanel(),

                        const SizedBox(height: 20),

                        // Thanh Tìm Kiếm
                        TextField(
                          onChanged: (value) =>
                              setState(() => _keyword = value),
                          decoration: InputDecoration(
                            hintText: 'Tìm món yêu thích...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _blueDeep,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Danh mục món',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _blueDeep,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tab danh mục
                        SizedBox(
                          height: 40,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dynamicCategories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = dynamicCategories[index];
                              final isSelected = cat == _selectedCategory;
                              return ChoiceChip(
                                label: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : _blueDeep,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: _blueDeep,
                                backgroundColor: Colors.white,
                                onSelected: (val) =>
                                    setState(() => _selectedCategory = cat),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'Thực đơn (${filteredDrinks.length} món)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _blueDeep,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Lưới Món Ăn
                        GridView.builder(
                          itemCount: filteredDrinks.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent:
                                    245, // ĐÃ SỬA: Tăng chiều cao để không bị ép chữ
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final drink = filteredDrinks[index];
                            final qty = _quantityOf(drink.id);

                            return Card(
                              elevation: 0,
                              color: drink.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          (drink.imageUrl != null &&
                                              drink.imageUrl!.isNotEmpty)
                                          ? NetworkImage(drink.imageUrl!)
                                          : null,
                                      child:
                                          (drink.imageUrl == null ||
                                              drink.imageUrl!.isEmpty)
                                          ? Icon(drink.icon, color: _blueDeep)
                                          : null,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      drink.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _money(drink.price),
                                      style: const TextStyle(
                                        color: _blueDeep,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (qty == 0)
                                      SizedBox(
                                        width: double.infinity,
                                        height: 38,
                                        child: ElevatedButton(
                                          onPressed: () => _addDrink(drink),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets
                                                .zero, // ĐÃ SỬA: Bỏ padding thừa
                                            backgroundColor: _blueDeep,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Thêm',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  _removeDrink(drink.id),
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 18,
                                                color: _blueDeep,
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  '$qty',
                                                  style: const TextStyle(
                                                    color: _blueDeep,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () => _addDrink(drink),
                                              icon: const Icon(
                                                Icons.add,
                                                size: 18,
                                                color: _blueDeep,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Thanh giỏ hàng bên dưới
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: _blueSoft,
                        child: Icon(Icons.shopping_bag, color: _blueDeep),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_totalItems món',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _money(currentTotalPrice),
                              style: const TextStyle(
                                color: _blueDeep,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ĐÃ SỬA: Nút thanh toán gọi hàm _checkout()
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _totalItems == 0
                            ? null
                            : () => _checkout(currentTotalPrice),
                        child: const Text(
                          'Thanh toán',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm chuyển hướng sang màn hình thanh toán
  void _checkout(int total) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          totalAmount: total,
          cart: _cart,
          cartItems: _cartItems,
        ),
      ),
    );

    // Nếu màn hình thanh toán trả về true, xóa giỏ hàng
    if (result == true) {
      setState(() {
        _cart.clear();
        _cartItems.clear();
      });
    }
  }
}
