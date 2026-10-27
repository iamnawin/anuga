import 'package:shared_dart/shared_dart.dart';

/// In-memory stand-in for the database RPCs a companion uses. It applies the
/// same rules as SQL: transitions from the shared state machine (checked against
/// SQL by the contract tests), pickup only through the OTP, attempt limit, and
/// "not allowed" for trips assigned to someone else.
class FakeBackend {
  FakeBackend({this.companionId = 'asha', this.maxOtpAttempts = 5});

  final String companionId;
  final int maxOtpAttempts;
  final Map<String, FakeTrip> trips = {};
  final List<String> calls = [];

  FakeTrip addTrip(FakeTrip trip) => trips[trip.id] = trip;

  CompanionApi get api => CompanionApi(rpc);

  Future<Object?> rpc(String function, Map<String, Object?> params) async {
    calls.add(function);
    switch (function) {
      case 'companion_my_trips':
        return [
          for (final t in trips.values)
            if (t.companionId == companionId) t.toCompanionRow(),
        ];
      case 'advance_trip':
        final trip = _mine(params['p_trip_id']! as String);
        final to = TripStatus.fromDb(params['p_to_status']! as String);
        if (!TripStateMachine.instance.canAdvance(trip.status, to, TransitionActor.companion)) {
          throw RpcException('22023', 'transition ${trip.status.dbValue} -> ${to.dbValue} not allowed for companion');
        }
        trip.apply(to, params['p_note'] as String?);
        return trip.toTripRow();
      case 'verify_pickup_otp':
        final trip = _mine(params['p_trip_id']! as String);
        if (trip.status != TripStatus.companionEnRoute) {
          throw const RpcException('22023', 'trip is not awaiting pickup');
        }
        if (trip.otp == null || trip.otpAttempts >= maxOtpAttempts) {
          return {'ok': false, 'reason': 'no_valid_code', 'attempts_left': 0};
        }
        if (params['p_code'] != trip.otp) {
          trip.otpAttempts++;
          return {'ok': false, 'reason': 'wrong_code', 'attempts_left': maxOtpAttempts - trip.otpAttempts};
        }
        trip.otp = null;
        trip.apply(TripStatus.pickedUp, 'pickup OTP verified');
        return {'ok': true, 'status': trip.status.dbValue};
      default:
        throw UnsupportedError('fake backend has no $function');
    }
  }

  FakeTrip _mine(String id) {
    final trip = trips[id];
    if (trip == null || trip.companionId != companionId) throw const RpcException('42501', 'not allowed');
    return trip;
  }
}

class FakeTrip {
  FakeTrip({
    required this.id,
    required this.pickupAt,
    this.status = TripStatus.scheduled,
    this.companionId = 'asha',
    this.detailsVisible = true,
    this.otp,
    this.startAllowedAt,
  });

  final String id;
  final DateTime pickupAt;
  final DateTime? startAllowedAt;
  TripStatus status;
  String companionId;
  bool detailsVisible;
  String? otp;
  int otpAttempts = 0;
  String? postVisitNote;
  final List<({TripStatus to, String? note})> events = [];

  void apply(TripStatus to, String? note) {
    status = to;
    if (to == TripStatus.completed && note != null) postVisitNote = note;
    events.add((to: to, note: note));
  }

  Map<String, Object?> toCompanionRow() => {
    'trip_id': id,
    'scheduled_pickup_at': pickupAt.toUtc().toIso8601String(),
    'scheduled_return_at': pickupAt.add(const Duration(hours: 5)).toUtc().toIso8601String(),
    'status': status.dbValue,
    'centre_name': 'Synthetic Dialysis Centre 1',
    'centre_address': '1 Example Road, Hyderabad (synthetic)',
    'details_visible': detailsVisible,
    'patient_name': detailsVisible ? 'Lakshmi Rao (synthetic)' : null,
    'home_address': detailsVisible ? '22 Sample Colony, Hyderabad (synthetic)' : null,
    'home_lat': detailsVisible ? 17.495 : null,
    'home_lng': detailsVisible ? 78.405 : null,
    'mobility_notes': detailsVisible ? 'Uses a walking stick; needs help on stairs' : null,
    'emergency_contacts': detailsVisible
        ? [
            {'name': 'Kiran Rao (synthetic)', 'phone': '+919000000101', 'relation': 'son'},
          ]
        : null,
    'start_allowed_at': startAllowedAt?.toUtc().toIso8601String(),
  };

  Map<String, Object?> toTripRow() => {
    'id': id,
    'patient_id': 'patient-1',
    'status': status.dbValue,
    'scheduled_pickup_at': pickupAt.toUtc().toIso8601String(),
    'scheduled_return_at': pickupAt.add(const Duration(hours: 5)).toUtc().toIso8601String(),
    'companion_id': companionId,
    'post_visit_note': postVisitNote,
  };
}

class FakePhoneAuth implements PhoneAuth {
  FakePhoneAuth({this.roles = const {'+919000000201': 'companion', '+919000000101': 'family'}, this.code = '123456'});

  final Map<String, String> roles;
  final String code;
  String? _pending;
  String? _signedInAs;

  @override
  bool get isSignedIn => _signedInAs != null;

  @override
  Future<void> sendCode(String phone) async {
    if (!roles.containsKey(phone)) throw const PhoneAuthException('Signups not allowed for otp');
    _pending = phone;
  }

  @override
  Future<void> verifyCode(String phone, String code) async {
    if (phone != _pending || code != this.code) throw const PhoneAuthException('Token has expired or is invalid');
    _signedInAs = phone;
  }

  @override
  Future<String?> currentRole() async => roles[_signedInAs];

  @override
  Future<void> signOut() async => _signedInAs = null;
}
