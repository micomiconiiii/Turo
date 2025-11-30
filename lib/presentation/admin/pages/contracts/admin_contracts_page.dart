import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:turo/services/admin_service.dart';
import 'package:turo/models/contract_model.dart';

class AdminContractsPage extends StatefulWidget {
  const AdminContractsPage({super.key});

  @override
  State<AdminContractsPage> createState() => _AdminContractsPageState();
}

class _AdminContractsPageState extends State<AdminContractsPage>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 Tabs: Disputes, Active, All
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // SEEDER BUTTON (Debug Only)
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                try {
                  await _adminService.seedTestContract();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Test Dispute Generated!'),
                        backgroundColor: Color(0xFF10403B),
                      ),
                    );
                  }
                } catch (e) {
                  print(e);
                }
              },
              label: const Text("Seed Dispute"),
              icon: const Icon(Icons.gavel),
              backgroundColor:
                  Colors.redAccent, // Distinct color for debug action
              foregroundColor:
                  Colors.white, // FIX: Forces text/icon to be white
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // DESCRIPTION (Title handled by Shell)
            Text(
              'Monitor mentorship agreements, escrow status, and resolve disputes.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF414480).withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // TAB BAR
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF10403B),
                labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF10403B),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Action Needed'),
                      ],
                    ),
                  ),
                  Tab(text: 'Active Contracts'),
                  Tab(text: 'All History'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // MAIN CONTENT (TAB VIEWS)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: StreamBuilder<List<ContractModel>>(
                    stream: _adminService.streamContracts(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error loading data: ${snapshot.error}"),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF10403B),
                          ),
                        );
                      }

                      final allContracts = snapshot.data ?? [];

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Disputes Only
                          _ContractList(
                            contracts: allContracts
                                .where((c) => c.status == 'disputed')
                                .toList(),
                            adminService: _adminService,
                            isDisputeTab: true,
                          ),
                          // Tab 2: Active Only
                          _ContractList(
                            contracts: allContracts
                                .where(
                                  (c) =>
                                      c.status == 'active' ||
                                      c.status == 'in_escrow',
                                )
                                .toList(),
                            adminService: _adminService,
                          ),
                          // Tab 3: All
                          _ContractList(
                            contracts: allContracts,
                            adminService: _adminService,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractList extends StatelessWidget {
  final List<ContractModel> contracts;
  final AdminService adminService;
  final bool isDisputeTab;

  const _ContractList({
    required this.contracts,
    required this.adminService,
    this.isDisputeTab = false,
  });

  @override
  Widget build(BuildContext context) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF10403B).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDisputeTab
                    ? Icons.check_circle_outline
                    : Icons.assignment_outlined,
                size: 48,
                color: const Color(0xFF10403B).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isDisputeTab
                  ? "No disputes requiring attention."
                  : "No contracts found.",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.grey.shade200,
        dataTableTheme: DataTableThemeData(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF9F9FA)),
          headingTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
          dataRowColor: MaterialStateProperty.all(Colors.white),
          dataTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 32,
          headingRowHeight: 50,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 60,
          columns: const [
            DataColumn(label: Text('CONTRACT ID')),
            DataColumn(label: Text('PARTIES')),
            DataColumn(label: Text('AMOUNT')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('ACTION')),
          ],
          rows: contracts.map((contract) {
            return DataRow(
              cells: [
                // ID Cell
                DataCell(
                  Text(
                    contract.contractId.length > 8
                        ? "...${contract.contractId.substring(contract.contractId.length - 8)}"
                        : contract.contractId,
                    style: const TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // Parties Cell
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Mentor: ${contract.mentorId.substring(0, 5)}...",
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        "Mentee: ${contract.menteeId.substring(0, 5)}...",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount Cell
                DataCell(
                  Text(
                    "PHP ${contract.rate.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                // Status Cell
                DataCell(_buildStatusBadge(contract.status)),
                // Action Cell
                DataCell(
                  isDisputeTab
                      ? ElevatedButton.icon(
                          onPressed: () =>
                              _showResolutionDialog(context, contract),
                          icon: const Icon(Icons.gavel, size: 16),
                          label: const Text("Resolve"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          tooltip: "View Details",
                          onPressed: () => _showContractDetails(
                            context,
                            contract,
                          ), // FIX: Now connects to function
                        ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'active':
      case 'in_escrow':
        color = const Color(0xFF10403B);
        icon = Icons.sync;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'disputed':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // --- DIALOG: RESOLVE DISPUTE (Editable) ---
  void _showResolutionDialog(BuildContext context, ContractModel contract) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.all(24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.all(24),
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: Color(0xFF10403B), size: 28),
            SizedBox(width: 12),
            Text(
              "Resolve Dispute",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Review the details below and select a resolution action.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow("Contract ID", contract.contractId),
                    const Divider(height: 24),
                    _buildInfoRow(
                      "Amount Held",
                      "PHP ${contract.rate.toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Admin Decision Note",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: "Reason for decision (e.g. 'Mentor inactivity')",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF10403B),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Spacer(),
              // Refund Button (Outlined Red)
              OutlinedButton(
                onPressed: () async {
                  await adminService.resolveDispute(
                    contract.contractId,
                    'cancelled',
                    noteController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Refund Mentee"),
              ),
              const SizedBox(width: 12),
              // Release Button (Solid Brand Color)
              ElevatedButton(
                onPressed: () async {
                  await adminService.resolveDispute(
                    contract.contractId,
                    'completed',
                    noteController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10403B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Release Funds"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DIALOG: CONTRACT DETAILS (Read Only) ---
  void _showContractDetails(BuildContext context, ContractModel contract) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.all(24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.all(24),
        title: const Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: Color(0xFF10403B),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              "Contract Details",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATUS HEADER
                Row(
                  children: [
                    const Text(
                      "Current Status:",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(contract.status),
                  ],
                ),
                const SizedBox(height: 24),

                // FINANCIALS CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow("Contract ID", contract.contractId),
                      const Divider(height: 24),
                      _buildInfoRow(
                        "Mentor ID",
                        contract.mentorId.substring(0, 8),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        "Mentee ID",
                        contract.menteeId.substring(0, 8),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        "Agreed Rate",
                        "PHP ${contract.rate.toStringAsFixed(2)}",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // TERMS & AGREEMENT
                const Text(
                  "Agreement Terms",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    contract.terms.isNotEmpty
                        ? contract.terms
                        : "No specific terms listed.",
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),

                // TIMESTAMPS
                const SizedBox(height: 16),
                Text(
                  "Created: ${contract.createdAt.toString().split('.')[0]}",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10403B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
        ),
      ],
    );
  }
}
