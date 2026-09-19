import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await testBackendAPI();
  await sendSensorData();

  runApp(const UyiraranApp());
}

// ============================================================
// BACKEND TEST
// ============================================================

Future<void> testBackendAPI() async {
  print("Testing Backend...");

  try {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/'),
    );

    print("Backend Status: ${response.statusCode}");
    print("Backend Response: ${response.body}");
  } catch (e) {
    print("Backend Error: $e");
  }
}

// ============================================================
// SENSOR DATA POST
// ============================================================

Future<void> sendSensorData() async {
  print("Sending Sensor Data...");

  try {
    final response = await http.post(
      Uri.parse(
        'http://127.0.0.1:8000/api/sensor-data',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "worker_id": "WRK001",
        "h2s": 3.2,
        "location": "Plant 2",
        "device": "ESP32",
        "risk": "low",
        "exposer": 10,
      }),
    );

    print("Sensor Status: ${response.statusCode}");
    print("Sensor Response: ${response.body}");
  } catch (e) {
    print("Sensor Error: $e");
  }
}

// ============================================================
// APP
// ============================================================

class UyiraranApp extends StatelessWidget {
  const UyiraranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uyiraran',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        cardColor: const Color(0xFF111827),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),

        fontFamily: 'Arial',
      ),

      home: const SplashScreen(),
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Image.asset(
              'assets/uyiraran.jpeg',

              width: 150,
              height: 150,

              fit: BoxFit.contain,

              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.shield,
                  size: 100,
                  color: Colors.green,
                );
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'UYIRARAN',

              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Worker Safety Monitoring System',

              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            const CircularProgressIndicator(
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showMessage(
        "Please enter email and password",
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const ManagerDashboard(),
        ),
      );
    }

    on FirebaseAuthException catch (e) {
      showMessage(
        e.message ?? "Login failed",
      );
    }

    catch (e) {
      showMessage(
        "Something went wrong",
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // LOGIN UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 25,
            ),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),

              child: Column(
                children: [

                  // =================================================
                  // LOGO
                  // =================================================

                  Container(
                    width: 110,
                    height: 110,

                    padding: const EdgeInsets.all(10),

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(25),

                      color: const Color(0xFF111C2E),

                      border: Border.all(
                        color: Colors.white12,
                      ),
                    ),

                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(18),

                      child: Image.asset(
                        'assets/uyiraran.jpeg',

                        fit: BoxFit.contain,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.shield,
                            size: 65,
                            color: Colors.green,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =================================================
                  // TITLE
                  // =================================================

                  const Text(
                    "UYIRARAN",

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    "Manager Login",

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white60,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // =================================================
                  // EMAIL
                  // =================================================

                  TextField(
                    controller: emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: InputDecoration(
                      labelText: "Email Address",

                      hintText: "Enter your email",

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),

                      filled: true,

                      fillColor:
                          const Color(0xFF111C2E),

                      labelStyle: const TextStyle(
                        color: Colors.white70,
                      ),

                      hintStyle: const TextStyle(
                        color: Colors.white38,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide:
                            const BorderSide(
                          color: Colors.white24,
                        ),
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide:
                            const BorderSide(
                          color: Colors.white24,
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide:
                            const BorderSide(
                          color: Colors.green,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // PASSWORD
                  // =================================================

                  TextField(
                    controller: passwordController,

                    obscureText: hidePassword,

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: InputDecoration(
                      labelText: "Password",

                      hintText:
                          "Enter your password",

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            hidePassword =
                                !hidePassword;
                          });
                        },
                      ),

                      filled: true,

                      fillColor:
                          const Color(0xFF111C2E),

                      labelStyle: const TextStyle(
                        color: Colors.white70,
                      ),

                      hintStyle: const TextStyle(
                        color: Colors.white38,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide:
                            const BorderSide(
                          color: Colors.white24,
                        ),
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide:
                            const BorderSide(
                          color: Colors.white24,
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide:
                            const BorderSide(
                          color: Colors.green,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // =================================================
                  // FORGOT PASSWORD
                  // =================================================

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const ForgotPasswordPage(),
                          ),
                        );
                      },

                      child: const Text(
                        "Forgot Password?",

                        style: TextStyle(
                          color: Colors.green,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // LOGIN BUTTON
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed:
                          loading ? null : login,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        elevation: 0,
                      ),

                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "LOGIN",

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // CREATE ACCOUNT
                  // =================================================

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const CreateAccountPage(),
                        ),
                      );
                    },

                    child: const Text(
                      "Create Account",

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Worker Safety Monitoring System",

                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CREATE ACCOUNT
// ============================================================

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() =>
      _CreateAccountPageState();
}

class _CreateAccountPageState
    extends State<CreateAccountPage> {

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool loading = false;

  Future<void> createAccount() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      showMessage(
        "Please fill all fields",
      );

      return;
    }

    if (passwordController.text !=
        confirmController.text) {
      showMessage(
        "Passwords do not match",
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password:
            passwordController.text.trim(),
      );

      if (!mounted) return;

      showMessage(
        "Account created successfully",
      );

      Navigator.pop(context);
    }

    on FirebaseAuthException catch (e) {
      showMessage(
        e.message ??
            "Account creation failed",
      );
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Account",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [

            TextField(
              controller: nameController,

              decoration: inputDecoration(
                "Full Name",
                Icons.person_outline,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,

              keyboardType:
                  TextInputType.emailAddress,

              decoration: inputDecoration(
                "Email Address",
                Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: inputDecoration(
                "Password",
                Icons.lock_outline,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmController,

              obscureText: true,

              decoration: inputDecoration(
                "Confirm Password",
                Icons.lock_outline,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed:
                    loading ? null : createAccount,

                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "CREATE ACCOUNT",
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FORGOT PASSWORD
// ============================================================

class ForgotPasswordPage
    extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  final emailController =
      TextEditingController();

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      showMessage(
        "Enter your email",
      );

      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      showMessage(
        "Password reset email sent",
      );
    }

    on FirebaseAuthException catch (e) {
      showMessage(
        e.message ??
            "Unable to send reset email",
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Forgot Password",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [

            TextField(
              controller: emailController,

              keyboardType:
                  TextInputType.emailAddress,

              decoration: inputDecoration(
                "Email Address",
                Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: resetPassword,

                child: const Text(
                  "SEND RESET EMAIL",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MANAGER DASHBOARD
// ============================================================

class ManagerDashboard
    extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() =>
      _ManagerDashboardState();
}

class _ManagerDashboardState
    extends State<ManagerDashboard> {

  int selectedIndex = 0;

  final pages = const [
    DashboardPage(),
    WorkersPage(),
    ExposurePage(),
    AlertsPage(),
    ReportsPage(),
    MapPage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  final titles = const [
    "Dashboard",
    "Workers",
    "Exposure",
    "Alerts",
    "Reports",
    "Map View",
    "Analytics",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor:
            const Color(0xFF111827),

        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 25),

              const Icon(
                Icons.shield,
                size: 65,
                color: Colors.green,
              ),

              const SizedBox(height: 12),

              const Text(
                "UYIRARAN",

                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Safety Monitoring",

                style: TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView.builder(
                  itemCount: titles.length,

                  itemBuilder:
                      (context, index) {

                    final icons = [
                      Icons.dashboard_outlined,
                      Icons.people_outline,
                      Icons.warning_amber_outlined,
                      Icons.notifications_none,
                      Icons.description_outlined,
                      Icons.location_on_outlined,
                      Icons.analytics_outlined,
                      Icons.settings_outlined,
                    ];

                    return ListTile(
                      leading: Icon(
                        icons[index],

                        color:
                            selectedIndex ==
                                    index
                                ? Colors.green
                                : Colors.white70,
                      ),

                      title: Text(
                        titles[index],

                        style: TextStyle(
                          color:
                              selectedIndex ==
                                      index
                                  ? Colors.green
                                  : Colors.white,
                        ),
                      ),

                      selected:
                          selectedIndex == index,

                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),

                title: const Text(
                  "Logout",
                ),

                onTap: () async {
                  await FirebaseAuth.instance
                      .signOut();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          const LoginPage(),
                    ),

                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}

// ============================================================
// DASHBOARD PAGE
// ============================================================

class DashboardPage
    extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
            ),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        int safe = 0;
        int alert = 0;
        int danger = 0;

        double totalH2S = 0;
        int h2sCount = 0;

        final alerts =
            <Map<String, dynamic>>[];

        for (final doc in docs) {

          final data =
              doc.data()
                  as Map<String, dynamic>;

          final risk =
              data['risk']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          if (risk == 'low' ||
              risk == 'safe') {
            safe++;
          }

          else if (risk == 'medium' ||
              risk == 'alert') {
            alert++;
          }

          else if (risk == 'high' ||
              risk == 'danger') {
            danger++;
          }

          final h2sValue =
              double.tryParse(
            data['h2s']?.toString() ?? '',
          );

          if (h2sValue != null) {
            totalH2S += h2sValue;
            h2sCount++;
          }

          if (risk == 'medium' ||
              risk == 'alert' ||
              risk == 'high' ||
              risk == 'danger') {

            alerts.add({
              'name':
                  data['name']
                          ?.toString() ??
                      'Unknown Worker',

              'h2s':
                  data['h2s']
                          ?.toString() ??
                      '0',

              'risk': risk,
            });
          }
        }

        final averageH2S =
            h2sCount == 0
                ? 0
                : totalH2S / h2sCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                "Safety Overview",

                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Real-time worker monitoring",

                style: TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 25),

              GridView.count(
                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                crossAxisCount:
                    MediaQuery.of(context)
                                .size
                                .width >
                            800
                        ? 4
                        : 2,

                crossAxisSpacing: 15,
                mainAxisSpacing: 15,

                childAspectRatio: 1.5,

                children: [

                  dashboardCard(
                    "Workers",
                    docs.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),

                  dashboardCard(
                    "Safe",
                    safe.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),

                  dashboardCard(
                    "Alert",
                    alert.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),

                  dashboardCard(
                    "Danger",
                    danger.toString(),
                    Icons.dangerous,
                    Colors.red,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: dashboardInfoCard(
                      "Average H₂S",
                      "${averageH2S.toStringAsFixed(1)} ppm",
                      Icons.air,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: dashboardInfoCard(
                      "Connected Devices",
                      docs.length.toString(),
                      Icons.memory,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Recent Alerts",

                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              if (alerts.isEmpty)

                const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(20),

                    child: Row(
                      children: [

                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),

                        SizedBox(width: 12),

                        Text(
                          "No active alerts",
                        ),
                      ],
                    ),
                  ),
                )

              else

                ...alerts.take(5).map(
                  (alertData) {

                    return alertItem(
                      alertData['name'],
                      "${alertData['h2s']} ppm",
                      alertData['risk'],
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// WORKERS PAGE
// ============================================================

class WorkersPage
    extends StatelessWidget {
  const WorkersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
            ),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No workers found",
            ),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.all(20),

          itemCount: docs.length,

          itemBuilder:
              (context, index) {

            final data =
                docs[index].data()
                    as Map<String, dynamic>;

            final name =
                data['name']
                        ?.toString() ??
                    'Unknown Worker';

            final workerId =
                data['worker_id']
                        ?.toString() ??
                    '';

            final h2s =
                data['h2s']
                        ?.toString() ??
                    '0';

            final risk =
                data['risk']
                        ?.toString() ??
                    'low';

            final location =
                data['location']
                        ?.toString() ??
                    'Unknown';

            final device =
                data['device']
                        ?.toString() ??
                    'Unknown';

            final exposure =
                data['exposer']
                        ?.toString() ??
                    '0';

            return Card(
              margin:
                  const EdgeInsets.only(
                bottom: 14,
              ),

              child: ListTile(
                contentPadding:
                    const EdgeInsets.all(15),

                leading: CircleAvatar(
                  backgroundColor:
                      riskColor(risk),

                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  name,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                subtitle: Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 8,
                  ),

                  child: Text(
                    "$workerId  •  H₂S: $h2s ppm\n"
                    "$location  •  $device",
                  ),
                ),

                trailing: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Text(
                      risk.toUpperCase(),

                      style: TextStyle(
                        color:
                            riskColor(risk),

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Exp: $exposure",

                      style:
                          const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                          WorkerProfilePage(
                        data: data,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// WORKER PROFILE
// ============================================================

class WorkerProfilePage
    extends StatelessWidget {

  final Map<String, dynamic> data;

  const WorkerProfilePage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    final name =
        data['name']
                ?.toString() ??
            'Unknown Worker';

    final workerId =
        data['worker_id']
                ?.toString() ??
            '';

    final h2s =
        data['h2s']
                ?.toString() ??
            '0';

    final risk =
        data['risk']
                ?.toString() ??
            'low';

    final location =
        data['location']
                ?.toString() ??
            'Unknown';

    final device =
        data['device']
                ?.toString() ??
            'Unknown';

    final exposure =
        data['exposer']
                ?.toString() ??
            '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Worker Profile",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 45,

              child: Icon(
                Icons.person,
                size: 45,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              name,

              style: const TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              workerId,

              style: const TextStyle(
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 30),

            profileItem(
              "H₂S Level",
              "$h2s ppm",
              Icons.air,
            ),

            profileItem(
              "Location",
              location,
              Icons.location_on,
            ),

            profileItem(
              "Device",
              device,
              Icons.memory,
            ),

            profileItem(
              "Exposure",
              exposure,
              Icons.timer,
            ),

            profileItem(
              "Status",
              risk.toUpperCase(),
              Icons.health_and_safety,
              valueColor:
                  riskColor(risk),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EXPOSURE PAGE
// ============================================================

class ExposurePage
    extends StatelessWidget {

  const ExposurePage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        return ListView.builder(
          padding:
              const EdgeInsets.all(20),

          itemCount: docs.length,

          itemBuilder:
              (context, index) {

            final data =
                docs[index].data()
                    as Map<String, dynamic>;

            final name =
                data['name']
                        ?.toString() ??
                    'Unknown';

            final workerId =
                data['worker_id']
                        ?.toString() ??
                    '';

            final exposer =
                double.tryParse(
                      data['exposer']
                              ?.toString() ??
                          '0',
                    ) ??
                    0;

            return Card(
              margin:
                  const EdgeInsets.only(
                bottom: 15,
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        Text(
                          name,

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        Text(
                          workerId,

                          style:
                              const TextStyle(
                            color:
                                Colors.white60,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    LinearProgressIndicator(
                      value:
                          (exposer / 100)
                              .clamp(
                                0.0,
                                1.0,
                              ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Exposure: ${exposer.toStringAsFixed(0)}",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ============================================================
// ALERTS PAGE
// ============================================================

class AlertsPage
    extends StatelessWidget {

  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        final docs =
            snapshot.data?.docs ?? [];

        final alertWorkers =
            docs.where((doc) {

          final data =
              doc.data()
                  as Map<String, dynamic>;

          final risk =
              data['risk']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          return risk == 'medium' ||
              risk == 'alert' ||
              risk == 'high' ||
              risk == 'danger';

        }).toList();

        if (alertWorkers.isEmpty) {

          return const Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                Icon(
                  Icons.check_circle,
                  size: 70,
                  color: Colors.green,
                ),

                SizedBox(height: 15),

                Text(
                  "No active alerts",

                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding:
              const EdgeInsets.all(20),

          itemCount:
              alertWorkers.length,

          itemBuilder:
              (context, index) {

            final data =
                alertWorkers[index]
                    .data()
                    as Map<String, dynamic>;

            return alertItem(
              data['name']
                      ?.toString() ??
                  'Unknown Worker',

              "${data['h2s']?.toString() ?? '0'} ppm",

              data['risk']
                      ?.toString() ??
                  'alert',
            );
          },
        );
      },
    );
  }
}

// ============================================================
// REPORTS PAGE
// ============================================================

class ReportsPage
    extends StatelessWidget {

  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        final docs =
            snapshot.data?.docs ?? [];

        int safe = 0;
        int alert = 0;
        int danger = 0;

        for (final doc in docs) {

          final data =
              doc.data()
                  as Map<String, dynamic>;

          final risk =
              data['risk']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          if (risk == 'low' ||
              risk == 'safe') {
            safe++;
          }

          else if (risk == 'medium' ||
              risk == 'alert') {
            alert++;
          }

          else if (risk == 'high' ||
              risk == 'danger') {
            danger++;
          }
        }

        return ListView(
          padding:
              const EdgeInsets.all(20),

          children: [

            const Text(
              "Safety Report",

              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            reportTile(
              "Total Workers",
              docs.length.toString(),
              Icons.people,
            ),

            reportTile(
              "Safe Workers",
              safe.toString(),
              Icons.check_circle,
            ),

            reportTile(
              "Alert Workers",
              alert.toString(),
              Icons.warning,
            ),

            reportTile(
              "Danger Workers",
              danger.toString(),
              Icons.dangerous,
            ),

            const SizedBox(height: 20),

            const Text(
              "Report generation can be connected "
              "to PDF/Excel later.",

              style: TextStyle(
                color: Colors.white60,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// MAP PAGE
// ============================================================

class MapPage
    extends StatelessWidget {

  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        final docs =
            snapshot.data?.docs ?? [];

        return ListView(
          padding:
              const EdgeInsets.all(20),

          children: [

            Container(
              height: 250,

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xFF172033),

                borderRadius:
                    BorderRadius.circular(18),

                border: Border.all(
                  color: Colors.white12,
                ),
              ),

              child: const Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Icon(
                      Icons.location_on,
                      size: 70,
                      color: Colors.green,
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Worker Location Map",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Map integration can be connected here",

                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Worker Locations",

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...docs.map((doc) {

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              return Card(
                child: ListTile(

                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),

                  title: Text(
                    data['name']
                            ?.toString() ??
                        'Unknown',
                  ),

                  subtitle: Text(
                    data['location']
                            ?.toString() ??
                        'Unknown location',
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ============================================================
// ANALYTICS PAGE
// ============================================================

class AnalyticsPage
    extends StatelessWidget {

  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),

      builder: (context, snapshot) {

        final docs =
            snapshot.data?.docs ?? [];

        double totalH2S = 0;
        int count = 0;

        double totalExposure = 0;

        for (final doc in docs) {

          final data =
              doc.data()
                  as Map<String, dynamic>;

          final h2s =
              double.tryParse(
                    data['h2s']
                            ?.toString() ??
                        '0',
                  ) ??
                  0;

          final exposure =
              double.tryParse(
                    data['exposer']
                            ?.toString() ??
                        '0',
                  ) ??
                  0;

          totalH2S += h2s;
          totalExposure += exposure;

          count++;
        }

        final averageH2S =
            count == 0
                ? 0
                : totalH2S / count;

        final averageExposure =
            count == 0
                ? 0
                : totalExposure / count;

        return ListView(
          padding:
              const EdgeInsets.all(20),

          children: [

            const Text(
              "Safety Analytics",

              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            analyticsCard(
              "Average H₂S",
              "${averageH2S.toStringAsFixed(2)} ppm",
              Icons.air,
            ),

            analyticsCard(
              "Average Exposure",
              averageExposure
                  .toStringAsFixed(1),
              Icons.timer,
            ),

            analyticsCard(
              "Total Workers",
              docs.length.toString(),
              Icons.people,
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// SETTINGS PAGE
// ============================================================

class SettingsPage
    extends StatelessWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(
      padding:
          const EdgeInsets.all(20),

      children: [

        const Text(
          "Settings",

          style: TextStyle(
            fontSize: 25,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: Column(
            children: [

              ListTile(
                leading: const Icon(
                  Icons.notifications_outlined,
                ),

                title: const Text(
                  "Notifications",
                ),

                trailing: Switch(
                  value: true,

                  onChanged: (_) {},
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.security_outlined,
                ),

                title: const Text(
                  "Security",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),

              const Divider(),

              const ListTile(
                leading: Icon(
                  Icons.info_outline,
                ),

                title: Text(
                  "About Uyiraran",
                ),

                subtitle: Text(
                  "Worker Safety Monitoring System",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COMMON INPUT DECORATION
// ============================================================

InputDecoration inputDecoration(
  String label,
  IconData icon,
) {
  return InputDecoration(
    labelText: label,

    prefixIcon: Icon(icon),

    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(12),
    ),
  );
}

// ============================================================
// DASHBOARD CARD
// ============================================================

Widget dashboardCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Card(
    child: Padding(
      padding:
          const EdgeInsets.all(15),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: const TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            title,

            style: const TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// DASHBOARD INFO CARD
// ============================================================

Widget dashboardInfoCard(
  String title,
  String value,
  IconData icon,
) {
  return Card(
    child: Padding(
      padding:
          const EdgeInsets.all(18),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.green,
            size: 32,
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// ALERT ITEM
// ============================================================

Widget alertItem(
  String name,
  String h2s,
  String risk,
) {
  return Card(
    margin:
        const EdgeInsets.only(
      bottom: 12,
    ),

    child: ListTile(

      leading: CircleAvatar(
        backgroundColor:
            riskColor(risk),

        child: const Icon(
          Icons.warning,
          color: Colors.white,
        ),
      ),

      title: Text(
        name,

        style: const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),
      ),

      subtitle: Text(
        "H₂S: $h2s",
      ),

      trailing: Text(
        risk.toUpperCase(),

        style: TextStyle(
          color: riskColor(risk),

          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),
  );
}

// ============================================================
// PROFILE ITEM
// ============================================================

Widget profileItem(
  String title,
  String value,
  IconData icon, {
  Color? valueColor,
}) {
  return Card(
    margin:
        const EdgeInsets.only(
      bottom: 12,
    ),

    child: ListTile(

      leading: Icon(
        icon,
        color: Colors.green,
      ),

      title: Text(
        title,

        style: const TextStyle(
          color: Colors.white60,
        ),
      ),

      trailing: Text(
        value,

        style: TextStyle(
          fontWeight:
              FontWeight.bold,

          color: valueColor,
        ),
      ),
    ),
  );
}

// ============================================================
// REPORT TILE
// ============================================================

Widget reportTile(
  String title,
  String value,
  IconData icon,
) {
  return Card(
    margin:
        const EdgeInsets.only(
      bottom: 12,
    ),

    child: ListTile(

      leading: Icon(
        icon,
        color: Colors.green,
      ),

      title: Text(title),

      trailing: Text(
        value,

        style: const TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    ),
  );
}

// ============================================================
// ANALYTICS CARD
// ============================================================

Widget analyticsCard(
  String title,
  String value,
  IconData icon,
) {
  return Card(
    margin:
        const EdgeInsets.only(
      bottom: 15,
    ),

    child: Padding(
      padding:
          const EdgeInsets.all(20),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.green,
            size: 40,
          ),

          const SizedBox(width: 20),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                title,

                style:
                    const TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,

                style:
                    const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// RISK COLOR
// ============================================================

Color riskColor(String risk) {
  final value =
      risk.toLowerCase();

  if (value == 'high' ||
      value == 'danger') {
    return Colors.red;
  }

  if (value == 'medium' ||
      value == 'alert') {
    return Colors.orange;
  }

  return Colors.green;
}