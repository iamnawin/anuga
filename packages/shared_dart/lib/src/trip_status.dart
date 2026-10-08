/// Trip lifecycle. Values and order match `public.trip_status` in
/// supabase/migrations/20261008000100_core_schema.sql.
enum TripStatus {
  scheduled('scheduled'),
  companionEnRoute('companion_en_route'),
  pickedUp('picked_up'),
  atCentre('at_centre'),
  handedOver('handed_over'),
  sessionDone('session_done'),
  returning('returning'),
  droppedHome('dropped_home'),
  completed('completed'),
  cancelled('cancelled'),
  noShow('no_show'),
  issueReported('issue_reported');

  const TripStatus(this.dbValue);

  /// Value used by the database and the API.
  final String dbValue;

  static TripStatus fromDb(String value) => values.firstWhere(
    (s) => s.dbValue == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'unknown trip status'),
  );

  bool get isTerminal => this == completed || this == cancelled || this == noShow;
}

/// Who is changing the trip. Matches `public.transition_actor`.
enum TransitionActor {
  companion('companion'),
  ops('ops'),
  family('family');

  const TransitionActor(this.dbValue);

  final String dbValue;

  static TransitionActor fromDb(String value) => values.firstWhere(
    (a) => a.dbValue == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'unknown transition actor'),
  );
}
