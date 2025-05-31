import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Page Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn(String email, String password, BuildContext context) async {
    final storage = GetStorage();
    storage.erase();

    final url = Uri.parse('http://192.168.1.4:8000/api/login');

    final body = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login sukses: $data');

        storage.write('token', data['access_token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

      } else {
        print('Login gagal: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal!')),
        );
      }

    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text('Email'),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan email',
              ),
            ),
            SizedBox(height: 16),
            Text('Password'),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                signIn(emailController.text, passwordController.text, context);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void logout(BuildContext context) {
    final storage = GetStorage();
    storage.erase();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Utama'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerPage()));
              },
              child: Text('Customer Page'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductPage()));
              },
              child: Text('Product Page'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              child: Text('Profile Page'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionPage()));
              },
              child: Text('Transaction Page'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPage()));
              },
              child: Text('Category Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List customers = [];

  Future<void> fetchCustomers() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/customers');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          customers = data['data']['data'];
        });
      } else {
        print('Gagal ambil customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteCustomer(int id) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/customers/$id');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Customer berhasil dihapus');
        fetchCustomers();
      } else {
        print('Gagal hapus customer');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus customer!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer')),
      body: RefreshIndicator(
        onRefresh: fetchCustomers,
        child: ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return ListTile(
              title: Text(customer['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${customer['email']}'),
                  Text('Phone: ${customer['phone']}'),
                  Text('Address: ${customer['address']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCustomerPage(customer: customer),
                        ),
                      );
                      fetchCustomers();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteCustomer(customer['id']);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerPage()),
          );
          fetchCustomers();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCustomerPage extends StatelessWidget {
  AddCustomerPage({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<void> addCustomer(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/customers');

    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        print('Customer berhasil ditambahkan');
        Navigator.pop(context);
      } else {
        print('Gagal tambah customer');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal tambah customer!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Address',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addCustomer(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCustomerPage extends StatelessWidget {
  final Map customer;

  EditCustomerPage({super.key, required this.customer});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<void> updateCustomer(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/customers/${customer['id']}');

    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Customer berhasil diupdate');
        Navigator.pop(context);
      } else {
        print('Gagal update customer');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update customer!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = customer['name'];
    emailController.text = customer['email'];
    phoneController.text = customer['phone'];
    addressController.text = customer['address'];

    return Scaffold(
      appBar: AppBar(title: Text('Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Phone',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Address',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateCustomer(context);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map profile = {};

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> fetchProfile() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/profile');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profile = data['data'];
          nameController.text = profile['name'];
          emailController.text = profile['email'];
        });
      } else {
        print('Gagal ambil profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateProfile() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/profile');

    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'email': emailController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Profil berhasil diperbarui');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } else {
        print('Gagal update profile');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update profile!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/profile');

    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'password': 'password_dummy',
    };

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Akun berhasil dihapus');
        storage.erase();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
              (route) => false,
        );
      } else {
        print('Gagal hapus akun');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus akun!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateProfile();
              },
              child: Text('Update Profil'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                deleteAccount(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Hapus Akun'),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List transactions = [];

  Future<void> fetchTransactions() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/transactions');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          transactions = data['data'];
        });
      } else {
        print('Gagal ambil transaksi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/transactions/$id');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Transaksi berhasil dihapus');
        fetchTransactions();
      } else {
        print('Gagal hapus transaksi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus transaksi!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi')),
      body: RefreshIndicator(
        onRefresh: fetchTransactions,
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final trx = transactions[index];
            return ListTile(
              title: Text('Customer: ${trx['customer']['name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Produk: ${trx['product']['name']}'),
                  Text('Total Harga: Rp ${trx['total_price']}'),
                  Text('Tanggal: ${trx['transaction_date']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTransactionPage(transaction: trx),
                        ),
                      );
                      fetchTransactions();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteTransaction(trx['id']);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionPage()),
          );
          fetchTransactions();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  int? selectedCustomerId;
  int? selectedProductId;
  int selectedProductPrice = 0;
  int totalPrice = 0;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List customers = [];
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchCustomers();
    await fetchProducts();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCustomers() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/customers');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        customers = data['data']['data'];
      }
    } catch (e) {
      print('Error fetch customers: $e');
    }
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/products');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        products = data['data']['data'];
      }
    } catch (e) {
      print('Error fetch products: $e');
    }
  }

  Future<void> addTransaction(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/transactions');
    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'customer_id': selectedCustomerId,
      'product_id': selectedProductId,
      'quantity': int.tryParse(quantityController.text) ?? 1,
      'transaction_date': dateController.text,
    };

    print('Add Transaction body: $body');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        print('Transaksi berhasil ditambahkan');
        Navigator.pop(context);
      } else {
        print('Gagal tambah transaksi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal tambah transaksi!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Tambah Transaksi')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Tambah Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
              value: selectedCustomerId,
              items: customers
                  .map<DropdownMenuItem<int>>((customer) => DropdownMenuItem(
                value: customer['id'],
                child: Text(customer['name']),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCustomerId = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Customer',
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedProductId,
              items: products
                  .map<DropdownMenuItem<int>>((product) => DropdownMenuItem(
                value: product['id'],
                child: Text(product['name']),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductId = value;

                  // Update harga sesuai produk yang dipilih
                  final selectedProduct = products.firstWhere((p) => p['id'] == value);
                  selectedProductPrice = int.tryParse(selectedProduct['price'].toString()) ?? 0;

                  totalPrice = selectedProductPrice * (int.tryParse(quantityController.text) ?? 0);
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quantity',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  totalPrice = selectedProductPrice * (int.tryParse(value) ?? 0);
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tanggal Transaksi (YYYY-MM-DD)',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Harga: Rp $totalPrice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addTransaction(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditTransactionPage extends StatefulWidget {
  final Map transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  int? selectedCustomerId;
  int? selectedProductId;
  int selectedProductPrice = 0;
  int totalPrice = 0;

  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  List customers = [];
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await fetchCustomers();
    await fetchProducts();

    // Setelah data di-load, set initial value:
    selectedCustomerId = widget.transaction['customer']['id'];
    selectedProductId = widget.transaction['product']['id'];
    selectedProductPrice = int.tryParse(widget.transaction['product']['price'].toString()) ?? 0;
    quantityController.text = widget.transaction['quantity'].toString();
    dateController.text = widget.transaction['transaction_date'];

    totalPrice = selectedProductPrice * (int.tryParse(quantityController.text) ?? 0);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchCustomers() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/customers');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        customers = data['data']['data'];
      }
    } catch (e) {
      print('Error fetch customers: $e');
    }
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/products');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        products = data['data']['data'];
      }
    } catch (e) {
      print('Error fetch products: $e');
    }
  }

  Future<void> updateTransaction(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/transactions/${widget.transaction['id']}');
    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'customer_id': selectedCustomerId,
      'product_id': selectedProductId,
      'quantity': int.tryParse(quantityController.text) ?? 1,
      'transaction_date': dateController.text,
    };

    print('Update body: $body');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Transaksi berhasil diupdate');
        Navigator.pop(context);
      } else {
        print('Gagal update transaksi');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update transaksi!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Transaksi')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<int>(
              value: selectedCustomerId,
              items: customers
                  .map<DropdownMenuItem<int>>((customer) => DropdownMenuItem(
                value: customer['id'],
                child: Text(customer['name']),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCustomerId = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Customer',
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedProductId,
              items: products
                  .map<DropdownMenuItem<int>>((product) => DropdownMenuItem(
                value: product['id'],
                child: Text(product['name']),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductId = value;

                  // Update harga sesuai produk yang dipilih
                  final selectedProduct = products.firstWhere((p) => p['id'] == value);
                  selectedProductPrice = int.tryParse(selectedProduct['price'].toString()) ?? 0;

                  totalPrice = selectedProductPrice * (int.tryParse(quantityController.text) ?? 0);
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Product',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quantity',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  totalPrice = selectedProductPrice * (int.tryParse(value) ?? 0);
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Tanggal Transaksi (YYYY-MM-DD)',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Harga: Rp $totalPrice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateTransaction(context);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List products = [];

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/products');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['data']['data'];
        });
      } else {
        print('Gagal ambil produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/products/$id');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Produk berhasil dihapus');
        fetchProducts();
      } else {
        print('Gagal hapus produk');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus produk!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produk')),
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga: Rp ${product['price']}'),
                  Text('Kategori: ${product['category']['name']}'),
                  Text('Deskripsi: ${product['description']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProductPage(product: product),
                        ),
                      );
                      fetchProducts();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteProduct(product['id']);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
          fetchProducts();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/categories');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = data['data']['data'];
        });
      } else {
        print('Gagal ambil kategori');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addProduct(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/products');
    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'description': descriptionController.text,
      'price': int.tryParse(priceController.text) ?? 0,
      'category_id': selectedCategoryId ?? 1
    };
    print('Selected Category ID: $selectedCategoryId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 201) {
        print('Produk berhasil ditambahkan');
        Navigator.pop(context);
      } else {
        print('Gagal tambah produk');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal tambah produk!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Deskripsi',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Harga',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('Kategori:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedCategoryId,
              items: categories.map<DropdownMenuItem<int>>((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              hint: Text('Pilih Kategori'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addProduct(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProductPage extends StatefulWidget {
  final Map product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.product['name'];
    descriptionController.text = widget.product['description'];
    priceController.text = widget.product['price'].toString();
    selectedCategoryId = widget.product['category']['id'];

    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/categories');
    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories = data['data']['data']; // kalau pakai pagination
          // kalau tanpa pagination: categories = data['data'];
        });
      } else {
        print('Gagal ambil kategori');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateProduct(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/products/${widget.product['id']}');

    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'description': descriptionController.text,
      'price': int.tryParse(priceController.text) ?? 0,
      'category_id': selectedCategoryId ?? 1,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        print('Produk berhasil diupdate');
        Navigator.pop(context);
      } else {
        print('Gagal update produk');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update produk!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Deskripsi',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Harga',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('Kategori:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedCategoryId,
              items: categories.map<DropdownMenuItem<int>>((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              hint: Text('Pilih Kategori'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                updateProduct(context);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List products = [];

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://192.168.1.4:8000/api/categories');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['data']['data'];
        });
      } else {
        print('Gagal ambil produk: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/categories/$id');

    final storage = GetStorage();
    final token = storage.read('token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Produk berhasil dihapus');
        fetchProducts();
      } else {
        print('Gagal hapus produk');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus produk!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kategori')),
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProductPage(product: product),
                        ),
                      );
                      fetchProducts();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteProduct(product['id']);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCategoryPage()),
          );
          fetchProducts();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List categories = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> addProduct(BuildContext context) async {
    final url = Uri.parse('http://192.168.1.4:8000/api/categories');
    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'description': descriptionController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 201) {
        print('Produk berhasil ditambahkan');
        Navigator.pop(context);
      } else {
        print('Gagal tambah produk');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal tambah produk!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Deskripsi',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                addProduct(context);
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditCategoryPage extends StatefulWidget {
  final Map product;

  const EditCategoryPage({super.key, required this.product});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product.isNotEmpty) {
      nameController.text = widget.product['name'] ?? '';
      descriptionController.text = widget.product['description'] ?? '';
    }
  }

  Future<void> updateProduct(BuildContext context) async {
    if (!widget.product.containsKey('id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID kategori tidak valid!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://192.168.1.4:8000/api/categories/${widget.product['id']}');
    final storage = GetStorage();
    final token = storage.read('token');

    final body = {
      'name': nameController.text,
      'description': descriptionController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Kategori')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Deskripsi',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () => updateProduct(context),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}







