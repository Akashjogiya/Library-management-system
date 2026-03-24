import 'dart:ui';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Theme Colors
  static const Color violet = Color(0xFFA855F7);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color navyBg = Color(0xFF020817);

  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  // Search Logic
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _quotes =  [
    {"q": "I have always imagined that Paradise will be a kind of a library.", "a": "Jorge Luis Borges"},
    {"q": "There is no friend as loyal as a book.", "a": "Ernest Hemingway"},
    {"q": "Everything you need for better future and success has already been written.", "a": "Jim Rohn"},
    {"q": "A room without books is like a body without a soul.", "a": "Marcus Tullius Cicero"},
    {"q": "Books are a uniquely portable magic.", "a": "Stephen King"},
    {"q": "The only thing that you absolutely have to know, is the location of the library.", "a": "Albert Einstein"},
    {"q": "Reading is essential for those who seek to rise above the ordinary.", "a": "Jim Rohn"},
    {"q": "Today a reader, tomorrow a leader.", "a": "Margaret Fuller"},
    {"q": "A book is a dream that you hold in your hand.", "a": "Neil Gaiman"},
    {"q": "I think of lotteries as a tax on people who are bad at math.", "a": "Cormac McCarthy"},
    {"q": "Words can be like X-rays if you use them properly.", "a": "Aldous Huxley"},
    {"q": "Not all those who wander are lost.", "a": "J.R.R. Tolkien"},
    {"q": "To read is to fly: it is to soar to a point of vantage.", "a": "A.C. Benson"},
    {"q": "Libraries were full of ideas—the most dangerous of all weapons.", "a": "Sarah J. Maas"},
    {"q": "Books are the quietest and most constant of friends.", "a": "Charles William Eliot"},
  ];

  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. ISSUE LOGIC (With Due Date Selection) ---
  Future<void> _issueBook(String docId, String title) async {
    final nameController = TextEditingController();
    final rollController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: navyBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: cyan, width: 0.5)),
            title: Text("Issue: $title", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPopupInput(nameController, "Student Name", Icons.person_outline),
                const SizedBox(height: 15),
                _buildPopupInput(rollController, "Roll Number / ID", Icons.badge_outlined),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Due Date:", style: TextStyle(color: Colors.white38, fontSize: 13)),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (picked != null) setDialogState(() => dueDate = picked);
                      },
                      icon: const Icon(Icons.calendar_month, color: violet, size: 18),
                      label: Text(DateFormat('MMM dd, yyyy').format(dueDate), style: const TextStyle(color: cyan)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('books').doc(docId).update({
                      'status': 'Issued',
                      'issuedTo': nameController.text.trim(),
                      'studentId': rollController.text.trim(),
                      'issuedAt': FieldValue.serverTimestamp(),
                      'dueDate': Timestamp.fromDate(dueDate),
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: const Text("CONFIRM ISSUE", style: TextStyle(color: navyBg, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 2. RETURN LOGIC ---
  Future<void> _returnBook(String docId, String title, Map<String, dynamic> data) async {
    String student = data['issuedTo'] ?? "Unknown";
    DateTime? due = (data['dueDate'] as Timestamp?)?.toDate();

    return showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: navyBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.orangeAccent, width: 0.5)),
          title: const Text("Return Volume", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Volume: $title", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Text("Issued to: $student", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              if (due != null) Text("Due Date: ${DateFormat('MMM dd, yyyy').format(due)}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 20),
              const Text("Mark this volume as returned?", style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('books').doc(docId).update({
                  'status': 'Available',
                  'issuedTo': null, 'studentId': null, 'issuedAt': null, 'dueDate': null,
                });
                if (mounted) Navigator.pop(context);
              },
              child: const Text("RETURN TO SHELF", style: TextStyle(color: navyBg, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBook(String docId, String title) async {
    return showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: navyBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withOpacity(0.2))),
          title: const Text("Purge Volume?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL", style: TextStyle(color: Colors.white38))),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('books').doc(docId).delete();
                if (mounted) Navigator.pop(context);
              },
              child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyBg,
      body: Stack(
        children: [
          Positioned(top: -100, left: 100, child: _blurCircle(300, violet.withOpacity(0.05))),
          Row(
            children: [
              _buildSidebar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _selectedIndex = i),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [ _buildDashboard(), _buildCatalog(), _buildHistory() ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: violet,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addBook),
        label: const Text("NEW ENTRY", style: TextStyle(color: navyBg, fontWeight: FontWeight.bold, letterSpacing: 1)),
        icon: const Icon(Icons.add, color: navyBg),
      ),
    );
  }

  // --- 1. DASHBOARD (Now with Circulation Table) ---
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome back, Reader", style: TextStyle(color: cyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 10),
          const Text("Registry Overview", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 40),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').snapshots(),
            builder: (context, snapshot) {
              int total = snapshot.hasData ? snapshot.data!.docs.length : 0;
              int issuedCount = snapshot.hasData ? snapshot.data!.docs.where((d) => (d.data() as Map)['status'] == 'Issued').length : 0;
              return Wrap(
                spacing: 25, runSpacing: 25,
                children: [
                  _buildStatCard("Total Volumes", total.toString(), Icons.auto_stories_rounded, violet, onTap: () => _pageController.jumpToPage(1)),
                  _buildStatCard("Issued Books", issuedCount.toString(), Icons.outbox_rounded, Colors.orangeAccent),
                  _buildStatCard("Active Members", "1", Icons.people_outline_rounded, cyan),
                  _buildStatCard("System Health", "Optimal", Icons.bolt_rounded, Colors.greenAccent),
                ],
              );
            }
          ),
          const SizedBox(height: 50),
          const Text("Active Circulations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _buildCirculationTable(),
          const SizedBox(height: 50),
          const Text("Literary Wisdom", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _buildQuoteGlass(), 
        ],
      ),
    );
  }

  Widget _buildCirculationTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').where('status', isEqualTo: 'Issued').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(15)), child: const Center(child: Text("No books are currently in circulation.", style: TextStyle(color: Colors.white24))));
        }
        return Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.03))),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              DateTime? due = (data['dueDate'] as Timestamp?)?.toDate();
              bool isOverdue = due != null && due.isBefore(DateTime.now());
              return ListTile(
                leading: const Icon(Icons.person_pin_rounded, color: violet),
                title: Text(data['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Issued to: ${data['issuedTo']}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: Text(due != null ? "Due: ${DateFormat('MMM dd').format(due)}" : "No Due Date", 
                  style: TextStyle(color: isOverdue ? Colors.redAccent : cyan, fontWeight: FontWeight.bold, fontSize: 12)),
              );
            },
          ),
        );
      },
    );
  }

  // --- 2. CATALOG ---
  Widget _buildCatalog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 60, 50, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Academic Catalog", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(width: 350, child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search by title...", hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: cyan, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.close, color: Colors.white38, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ""); }) : null,
                  filled: true, fillColor: Colors.white.withOpacity(0.02),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: violet, width: 1.5)),
                ),
              )),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: violet));
              var docs = snap.data?.docs.where((doc) => (doc.data() as Map)['title']?.toString().toLowerCase().contains(_searchQuery) ?? false).toList() ?? [];
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.65, crossAxisSpacing: 35, mainAxisSpacing: 45),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  String status = data['status'] ?? "Available";
                  return GestureDetector(
                    onTap: () => status == 'Available' ? _issueBook(doc.id, data['title']) : _returnBook(doc.id, data['title'], data),
                    child: Stack(children: [
                      _HoverBookCard(url: data['coverUrl'], title: data['title'], status: status),
                      Positioned(top: 5, right: 5, child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.3), size: 18), color: navyBg,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white10)),
                        onSelected: (val) { if (val == 'delete') _deleteBook(doc.id, data['title']); },
                        itemBuilder: (c) => [
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.white38, size: 16), SizedBox(width: 10), Text("Edit Meta", style: TextStyle(color: Colors.white70))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 16), SizedBox(width: 10), Text("Purge", style: TextStyle(color: Colors.redAccent))])),
                        ],
                      )),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 3. HISTORY ---
  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(50, 60, 50, 30), child: Text("Archive History", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white))),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('books').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: violet));
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 50), itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  DateTime? date = (data['createdAt'] as Timestamp?)?.toDate();
                  String time = date != null ? DateFormat('MMM dd, yyyy • HH:mm').format(date) : "Recent";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.015), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.03))),
                    child: Row(children: [
                      Icon(Icons.history_toggle_off, color: data['status'] == 'Issued' ? Colors.orangeAccent : cyan), const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("${data['status'] == 'Issued' ? 'Issued' : 'Action'}: ${data['title']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ])),
                      Text((data['status'] ?? "LOGGED").toUpperCase(), style: TextStyle(color: data['status'] == 'Issued' ? Colors.orangeAccent : Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.w900)),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- UI HELPERS ---
  Widget _buildPopupInput(TextEditingController c, String l, IconData i) {
    return TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: l, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12), prefixIcon: Icon(i, color: violet, size: 18), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: cyan))));
  }

  Widget _buildQuoteGlass() {
    return TweenAnimationBuilder<double>(duration: const Duration(seconds: 2), tween: Tween(begin: 0.0, end: 1.0), builder: (context, value, child) => Opacity(opacity: value, child: Container(width: double.infinity, padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.03))), child: Column(children: [const Icon(Icons.format_quote_rounded, color: violet, size: 40), const SizedBox(height: 20), Text("\"${_currentQuote['q']}\"", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic)), const SizedBox(height: 20), Text("— ${_currentQuote['a']}", style: const TextStyle(color: cyan, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12))]))));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(onTap: onTap, child: Container(width: 250, padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 30), const SizedBox(height: 25), Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1))])));
  }

  Widget _buildSidebar() {
    return Container(width: 260, decoration: BoxDecoration(color: Colors.white.withOpacity(0.01), border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05)))), child: Column(children: [const SizedBox(height: 60), const Icon(Icons.auto_awesome_mosaic_rounded, color: cyan, size: 40), const SizedBox(height: 60), _navItem(0, Icons.dashboard_outlined, "Dashboard"), _navItem(1, Icons.library_books_outlined, "Catalog"), _navItem(2, Icons.history_edu, "History"), const Spacer(), _navItem(-1, Icons.logout, "Exit System"), const SizedBox(height: 30)]));
  }

  Widget _navItem(int i, IconData ic, String l) {
    bool act = _selectedIndex == i;
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5), leading: Icon(ic, color: act ? violet : Colors.white38, size: 22), title: Text(l, style: TextStyle(color: act ? Colors.white : Colors.white38, fontSize: 15, fontWeight: act ? FontWeight.bold : FontWeight.normal)), onTap: () { if (i == -1) Navigator.pushReplacementNamed(context, '/login'); else _pageController.jumpToPage(i); });
  }

  Widget _blurCircle(double s, Color c) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}

class _HoverBookCard extends StatefulWidget {
  final String? url; final String title; final String status;
  const _HoverBookCard({required this.url, required this.title, required this.status});
  @override State<_HoverBookCard> createState() => _HoverBookCardState();
}

class _HoverBookCardState extends State<_HoverBookCard> {
  bool _isHovering = false;
  static const Color violet = Color(0xFFA855F7);
  static const Color cyan = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    bool isIssued = widget.status.toLowerCase() == 'issued';
    return MouseRegion(onEnter: (_) => setState(() => _isHovering = true), onExit: (_) => setState(() => _isHovering = false), child: AnimatedContainer(duration: const Duration(milliseconds: 200), transform: _isHovering ? (Matrix4.identity()..translate(0, -8)) : Matrix4.identity(), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), boxShadow: _isHovering ? [BoxShadow(color: violet.withOpacity(0.4), blurRadius: 25, spreadRadius: 2)] : []), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: _isHovering ? violet : Colors.white.withOpacity(0.08))), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: widget.url != null && widget.url!.isNotEmpty ? Image.network(widget.url!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.white10))) : Center(child: Icon(Icons.menu_book, color: Colors.white.withOpacity(0.05), size: 50))))), const SizedBox(height: 18), Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isIssued ? Colors.orangeAccent.withOpacity(0.1) : cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(widget.status.toUpperCase(), style: TextStyle(color: isIssued ? Colors.orangeAccent : cyan, fontSize: 9, fontWeight: FontWeight.bold)))])));
  }
}