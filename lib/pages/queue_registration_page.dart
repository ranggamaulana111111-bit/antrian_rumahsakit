
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_constants.dart';
import '../helpers/database_helper.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/queue.dart';
import '../models/specialist.dart';
import '../repositories/queue_repository.dart';
import '../services/auth_service.dart';

class QueueRegistrationPage extends StatefulWidget {
  const QueueRegistrationPage({super.key});

  @override
  State<QueueRegistrationPage> createState() => _QueueRegistrationPageState();
}

class _QueueRegistrationPageState extends State<QueueRegistrationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Antrean')),
      body: const QueueRegistrationForm(),
    );
  }
}

class QueueRegistrationForm extends StatefulWidget {
  const QueueRegistrationForm({super.key});

  @override
  State<QueueRegistrationForm> createState() => _QueueRegistrationFormState();
}

class _QueueRegistrationFormState extends State<QueueRegistrationForm> {
  final _namaController = TextEditingController();
  final _nikController = TextEditingController();
  final _hpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final QueueRepository _repo = QueueRepository();
  final AuthService _auth = AuthService();

  String? _selectedPoli;
  String? _selectedDoctorId;
  Doctor? _selectedDoctor;
  String? _selectedSchedule;
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 20));
  DateTime _visitDate = DateTime.now();
  String _jenisKelamin = 'Laki-laki';
  int _currentStep = 0;
  bool _isSubmitting = false;

  List<Doctor> _allDoctors = [];
  List<String> _poliList = PoliData.poliList;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadPoli();
    _prefillPatientData();
  }

  void _prefillPatientData() async {
    if (!_auth.isPasien) return;
    final patientId = _auth.currentUser?.patientId;
    if (patientId == null) return;
    try {
      final patient = await _repo.getPatientById(patientId);
      if (patient != null && mounted) {
        _namaController.text = patient.nama;
        _nikController.text = patient.nik;
        _hpController.text = patient.nomorHp;
        _jenisKelamin = patient.jenisKelamin;
        try {
          _birthDate = DateTime.parse(patient.tanggalLahir);
        } catch (_) {}
      }
    } catch (_) {}
  }

  void _loadPoli() async {
    try {
      final results = await DatabaseHelper().query('specialists', orderBy: 'nama');
      final specialists = results.map((m) => Specialist.fromMap(m)).toList();
      if (specialists.isNotEmpty) {
        if (mounted) setState(() => _poliList = specialists.map((s) => s.nama).toList());
      }
    } catch (_) {}
  }

  void _loadDoctors() async {
    try {
      final doctors = await _repo.getAllDoctors();
      if (mounted) setState(() => _allDoctors = doctors);
    } catch (e) {
      if (mounted) {
        setState(() => _allDoctors = []);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat dokter: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _hpController.dispose();
    super.dispose();
  }

  List<Doctor> get _doctorsForPoli {
    if (_selectedPoli == null) return [];
    return _allDoctors.where((d) => d.spesialis == _selectedPoli).toList();
  }

  List<String> get _scheduleLabels {
    if (_selectedDoctor == null) return [];
    return _selectedDoctor!.jadwal.map((s) => s.toString()).toList();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _namaController.text.trim().isNotEmpty &&
            _nikController.text.trim().length == 16 &&
            _hpController.text.trim().length >= 10;
      case 1:
        return _selectedPoli != null;
      case 2:
        return _selectedDoctorId != null;
      case 3:
        return _selectedSchedule != null;
      default:
        return true;
    }
  }

  String _fmt(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  String _iso(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _visitDate = picked);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final nik = _nikController.text.trim();

      final patient = Patient(
        nama: _namaController.text.trim(),
        nik: nik,
        nomorHp: _hpController.text.trim(),
        jenisKelamin: _jenisKelamin,
        tanggalLahir: _iso(_birthDate),
      );

      final savedPatient = await _repo.insertPatient(patient);
      if (savedPatient.id == null) {
        throw Exception('Gagal menyimpan data pasien');
      }

      final dateStr = _iso(_visitDate);

      final hasQueue = await _repo.hasQueueForPatientToday(
        savedPatient.id!,
        dateStr,
      );
      if (hasQueue) {
        throw Exception(
          'Pasien sudah terdaftar untuk tanggal ini',
        );
      }

      final queueNumber = await _repo.getNextQueueNumber(
        _selectedPoli!,
        dateStr,
      );
      final estimasi = await _repo.calculateEstimasi(
        _selectedDoctor!.id!,
        dateStr,
      );

      final queue = Queue(
        patientId: savedPatient.id!,
        doctorId: _selectedDoctor!.id!,
        nomorAntrean: queueNumber,
        tanggalKunjungan: dateStr,
        estimasiWaktu: estimasi,
        status: 'Menunggu',
      );

      final savedQueue = await _repo.insertQueue(queue);
      if (savedQueue.id == null) {
        throw Exception('Gagal menyimpan antrean');
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Pendaftaran Berhasil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.green, size: 64),
              const SizedBox(height: 16),
              const Text('Nomor Antrean Anda'),
              const SizedBox(height: 8),
              Text(
                queueNumber,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estimasi: $estimasi',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                _fmt(_visitDate),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _currentStep = 0;
      _namaController.clear();
      _nikController.clear();
      _hpController.clear();
      _selectedPoli = null;
      _selectedDoctorId = null;
      _selectedDoctor = null;
      _selectedSchedule = null;
      _birthDate = DateTime.now().subtract(const Duration(days: 365 * 20));
      _visitDate = DateTime.now();
      _jenisKelamin = 'Laki-laki';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _currentStep < 4
          ? () {
              if (_currentStep == 0) {
                if (_formKey.currentState?.validate() != true) return;
              } else if (!_canProceed) { return; }
              setState(() => _currentStep++);
            }
          : null,
      onStepCancel:
          _currentStep > 0 ? () => setState(() => _currentStep--) : null,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              if (_currentStep < 4)
                ElevatedButton(
                  onPressed: _canProceed ? details.onStepContinue : null,
                  child: const Text('Lanjut'),
                )
              else
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Daftar'),
                ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Kembali'),
                ),
              ],
            ],
          ),
        );
      },
      steps: [
        Step(
          title: const Text('Data Pasien'),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          content: _buildPatientStep(),
        ),
        Step(
          title: const Text('Pilih Poli'),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          content: _buildPoliStep(),
        ),
        Step(
          title: const Text('Pilih Dokter'),
          isActive: _currentStep >= 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          content: _buildDoctorStep(),
        ),
        Step(
          title: const Text('Jadwal & Tanggal'),
          isActive: _currentStep >= 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          content: _buildScheduleStep(),
        ),
        Step(
          title: const Text('Konfirmasi'),
          isActive: _currentStep >= 4,
          state: StepState.indexed,
          content: _buildConfirmStep(),
        ),
      ],
    );
  }

  Widget _buildPatientStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _namaController,
            decoration: const InputDecoration(
              labelText: 'Nama Pasien',
              prefixIcon: Icon(Icons.person),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nikController,
            decoration: const InputDecoration(
              labelText: 'NIK',
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
            maxLength: 16,
            textInputAction: TextInputAction.next,
            buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'NIK tidak boleh kosong';
              if (v.trim().length != 16) return 'NIK harus 16 digit';
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _hpController,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nomor HP tidak boleh kosong';
              if (v.trim().length < 10) return 'Nomor HP minimal 10 digit';
              return null;
            },
          ),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _jenisKelamin,
            onChanged: (v) { if (v != null) setState(() => _jenisKelamin = v); },
            child: Row(
              children: [
                const Text('Jenis Kelamin: '),
                const Radio<String>(value: 'Laki-laki'),
                const Text('Laki-laki'),
                const SizedBox(width: 16),
                const Radio<String>(value: 'Perempuan'),
                const Text('Perempuan'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Tanggal Lahir: '),
              TextButton.icon(
                onPressed: _pickBirthDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_fmt(_birthDate)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPoliStep() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPoli,
      decoration: const InputDecoration(
        labelText: 'Pilih Poli',
        prefixIcon: Icon(Icons.local_hospital),
      ),
      items: _poliList.map((poli) {
        return DropdownMenuItem(value: poli, child: Text(poli));
      }).toList(),
      onChanged: (v) {
        setState(() {
          _selectedPoli = v;
          _selectedDoctorId = null;
          _selectedDoctor = null;
          _selectedSchedule = null;
        });
      },
    );
  }

  Widget _buildDoctorStep() {
    if (_selectedPoli == null) {
      return const Text('Silakan pilih poli terlebih dahulu');
    }

    final doctors = _doctorsForPoli;
    if (doctors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              const Text(
                'Tidak ada dokter tersedia untuk poli ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _loadDoctors,
                icon: const Icon(Icons.refresh),
                label: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...doctors.map((d) {
          final selected = _selectedDoctorId == d.id.toString();
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDoctorId = d.id.toString();
                  _selectedDoctor = d;
                  _selectedSchedule = null;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.namaDokter,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.spesialis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildScheduleStep() {
    return Column(
      children: [
        Row(
          children: [
            const Text('Tanggal Kunjungan: '),
            TextButton.icon(
              onPressed: _pickVisitDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_fmt(_visitDate)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedDoctor == null)
          const Text('Silakan pilih dokter terlebih dahulu')
        else ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedSchedule,
            decoration: const InputDecoration(
              labelText: 'Pilih Jadwal',
              prefixIcon: Icon(Icons.schedule),
            ),
            items: _scheduleLabels.map((s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (v) => setState(() => _selectedSchedule = v),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confirmRow('Nama', _namaController.text.trim()),
            _confirmRow('NIK', _nikController.text.trim()),
            _confirmRow('No. HP', _hpController.text.trim()),
            _confirmRow('Jenis Kelamin', _jenisKelamin),
            _confirmRow('Tanggal Lahir', _fmt(_birthDate)),
            const Divider(height: 24),
            _confirmRow('Poli', _selectedPoli ?? '-'),
            _confirmRow('Dokter', _selectedDoctor?.namaDokter ?? '-'),
            _confirmRow('Jadwal', _selectedSchedule ?? '-'),
            _confirmRow('Tanggal Kunjungan', _fmt(_visitDate)),
          ],
        ),
      ),
    );
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
