
String getDayDiff(String deadLine){
  String daysLeft = '';
  if(deadLine.isNotEmpty){
    daysLeft = 'Hoy';
    DateTime dateCreate = DateTime.parse(deadLine);
    Duration difDays = dateCreate.difference(DateTime.now());
    int days = difDays.inDays;

    if(days > 0 || days < 0){
      daysLeft = '$days días';
      if(days == 1 || days == (-1)) { daysLeft = '$days día'; }
    }
  }
  return daysLeft;
}