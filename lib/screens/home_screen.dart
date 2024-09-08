import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reward_boy/screens/history_screen.dart';
import 'package:reward_boy/screens/offers_screen.dart';
import 'package:reward_boy/screens/profile_screen.dart';
import 'package:reward_boy/screens/quiz_screen.dart';
import 'package:reward_boy/screens/refer_earn_screen.dart';
import 'package:reward_boy/screens/spin_wheel_screen.dart';
import 'package:reward_boy/screens/wallet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeContent(),
    const ReferEarnScreen(),
    const WalletScreen(),
    const ProfileScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share),
            label: 'Refer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_rounded),
            label: 'Walet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

class BankCard extends StatelessWidget {
  const BankCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Total Balance:',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '\$1234.56',
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _walletBalance = '0';
  double _rupees = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String walletBalance = prefs.getString('walletBalance') ?? '0';
    setState(() {
      _walletBalance = walletBalance;
      setState(() {
        _walletBalance = walletBalance;
        _rupees = _convertToRupees(walletBalance);
      });
    });
  }

  double _convertToRupees(String balance) {
    try {
      double balanceInCents = double.parse(balance);
      return balanceInCents / 100;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ClipOval(
              child: Image(
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.contain,
                height: 40,
                width: 40,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'RewardBoy',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalletScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 160,
                        width: MediaQuery.sizeOf(context).width * 0.55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 16, 86, 177),
                              Color.fromARGB(255, 4, 50, 166),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Your Current Coins",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.monetization_on,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        _walletBalance,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Divider(
                                    endIndent: 90,
                                    thickness: 0.2,
                                  ),
                                  Text(
                                    "₹ $_rupees",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: 0.5,
                                child: Image(
                                  image: AssetImage(
                                    "assets/images/treasure.png",
                                  ),
                                  alignment: Alignment.bottomRight,
                                  width: 130,
                                  height: 130,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpinWheelScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 160,
                        width: MediaQuery.sizeOf(context).width * 0.40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 190, 24, 149),
                              Color.fromARGB(255, 95, 3, 74),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: const Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Daily Spin",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Spin a wheel to earn rewards.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: 0.4,
                                child: Image(
                                  image: AssetImage(
                                    "assets/images/roulette.png",
                                  ),
                                  alignment: Alignment.bottomRight,
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OffersScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 160,
                        width: MediaQuery.sizeOf(context).width * 0.40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 11, 170, 82),
                              Color.fromARGB(255, 3, 87, 51),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: const Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hot Offers",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Best offers to earn rewards.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: 0.6,
                                child: Image(
                                  image: AssetImage(
                                    "assets/images/rocket.png",
                                  ),
                                  alignment: Alignment.bottomRight,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 160,
                      width: MediaQuery.sizeOf(context).width * 0.55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 209, 41, 26),
                            Color.fromARGB(255, 94, 4, 4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Play Games",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Play games to \nearn rewards.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Opacity(
                              opacity: 0.5,
                              child: Image(
                                image: AssetImage(
                                  "assets/images/gamepad.png",
                                ),
                                alignment: Alignment.bottomRight,
                                width: 120,
                                height: 120,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 120,
                      width: MediaQuery.sizeOf(context).width * 0.55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 221, 143, 41),
                            Color.fromARGB(255, 127, 63, 4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "FAQ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Learn how to use our app ?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Opacity(
                              opacity: 0.5,
                              child: Image(
                                image: AssetImage(
                                  "assets/images/money.png",
                                ),
                                alignment: Alignment.bottomRight,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 120,
                      width: MediaQuery.sizeOf(context).width * 0.40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 110, 24, 190),
                            Color.fromARGB(255, 41, 3, 95),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Folow Us",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Telegram \nChannel",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Opacity(
                              opacity: 0.4,
                              child: Image(
                                image: AssetImage(
                                  "assets/images/social_media.png",
                                ),
                                alignment: Alignment.bottomRight,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 160,
                      width: MediaQuery.sizeOf(context).width * 0.55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 180, 172, 20),
                            Color.fromARGB(255, 91, 94, 2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(
                          top: BorderSide(color: Colors.black),
                          left: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: const Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Games Task",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Complete games to \nearn rewards.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Opacity(
                              opacity: 0.5,
                              child: Image(
                                image: AssetImage(
                                  "assets/images/task.png",
                                ),
                                alignment: Alignment.bottomRight,
                                width: 120,
                                height: 120,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 160,
                        width: MediaQuery.sizeOf(context).width * 0.40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 10, 129, 142),
                              Color.fromARGB(255, 2, 70, 82),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: const Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Quiz Game",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Text(
                                    "Complete Quiz to earn rewards.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: 0.4,
                                child: Image(
                                  image: AssetImage(
                                    "assets/images/swipe.png",
                                  ),
                                  alignment: Alignment.bottomRight,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 11, 73, 155),
                        Color.fromARGB(255, 4, 38, 126),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: const Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "RewardBoy Special",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Easy offers to get instant 1000 coins.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Opacity(
                          opacity: 0.5,
                          child: Image(
                            image: AssetImage(
                              "assets/images/gift.png",
                            ),
                            alignment: Alignment.bottomRight,
                            width: 90,
                            height: 90,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Hot Offerwalls 🔥",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 150,
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "* * * * *",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Image(
                            image: AssetImage(
                              "assets/images/logo.png",
                            ),
                            height: 70,
                          ),
                          Text(
                            "Pubscale",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 150,
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "* * * * *",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Image(
                            image: AssetImage(
                              "assets/images/logo.png",
                            ),
                            height: 70,
                          ),
                          Text(
                            "Pubscale",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 150,
                      width: MediaQuery.sizeOf(context).width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.green,
                            Colors.blue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "* * * * *",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                          Image(
                            image: AssetImage(
                              "assets/images/logo.png",
                            ),
                            height: 70,
                          ),
                          Text(
                            "Pubscale",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.pink,
                        Colors.red,
                      ],
                    ),
                  ),
                  child: const ListTile(
                    leading: Icon(
                      Icons.social_distance,
                      color: Colors.white,
                      size: 40,
                    ),
                    title: Text(
                      "Loved Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Enjoying our App? Rate us on Google Play! ",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.green,
                        Color.fromARGB(255, 18, 184, 26),
                        Color.fromARGB(255, 3, 109, 16),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const ListTile(
                    leading: Icon(
                      Icons.social_distance,
                      color: Colors.white,
                      size: 40,
                    ),
                    title: Text(
                      "Support !",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "RewardBoy always helps you.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
