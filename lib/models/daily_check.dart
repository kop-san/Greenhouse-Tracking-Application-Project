enum CheckStatus {
  Healthy,
  Disease,
  Virus,
  Rest
}

class DailyCheck {
  final String? checkId;
  final DateTime checkDate;
  final CheckStatus checkStatus;
  final double ec;
  final double ph;
  final double n;
  final double p;
  final double k;
  final double soilTemp;
  final double soilHumid;
  final double greenhouseTemp;
  final double greenhouseHumid;
  final String greenhouseId;
  final String userId;

  DailyCheck({
    this.checkId,
    required this.checkDate,
    required this.checkStatus,
    required this.ec,
    required this.ph,
    required this.n,
    required this.p,
    required this.k,
    required this.soilTemp,
    required this.soilHumid,
    required this.greenhouseTemp,
    required this.greenhouseHumid,
    required this.greenhouseId,
    required this.userId,
  });

  factory DailyCheck.fromJson(Map<String, dynamic> json) {
    return DailyCheck(
      checkId: json['check_id'],
      checkDate: DateTime.parse(json['check_date']),
      checkStatus: CheckStatus.values.firstWhere(
        (e) => e.toString() == 'CheckStatus.${json['check_status']}',
      ),
      ec: json['ec'].toDouble(),
      ph: json['ph'].toDouble(),
      n: json['n'].toDouble(),
      p: json['p'].toDouble(),
      k: json['k'].toDouble(),
      soilTemp: json['soil_temp'].toDouble(),
      soilHumid: json['soil_humid'].toDouble(),
      greenhouseTemp: json['greenhouse_temp'].toDouble(),
      greenhouseHumid: json['greenhouse_humid'].toDouble(),
      greenhouseId: json['greenhouse_id'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (checkId != null) 'check_id': checkId,
      'check_date': checkDate.toIso8601String(),
      'check_status': checkStatus.toString().split('.').last,
      'ec': ec,
      'ph': ph,
      'n': n,
      'p': p,
      'k': k,
      'soil_temp': soilTemp,
      'soil_humid': soilHumid,
      'greenhouse_temp': greenhouseTemp,
      'greenhouse_humid': greenhouseHumid,
      'greenhouse_id': greenhouseId,
      'user_id': userId,
    };
  }
} 