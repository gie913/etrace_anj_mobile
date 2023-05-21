import 'package:e_trace_app/database_local/database_collection_point.dart';
import 'package:e_trace_app/database_local/database_delivery_order.dart';
import 'package:e_trace_app/database_local/database_harvest_ticket.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CounterNotifier with ChangeNotifier {
  int? _countHarvestTicket, _countCollectionPoint, _countDeliveryOrder;
  DatabaseHarvestTicket databaseHarvestTicket = DatabaseHarvestTicket();
  DatabaseCollectionPoint databaseCollectionPoint = DatabaseCollectionPoint();
  DatabaseDeliveryOrder databaseDeliveryOrder = DatabaseDeliveryOrder();

  int? get countHarvestTicket => _countHarvestTicket;

  int? get countCollectionPoint => _countCollectionPoint;

  int? get countDeliveryOrder => _countDeliveryOrder;

  getCountUnUploadedHarvestTicket() async {
    _countHarvestTicket = 0;
    _countHarvestTicket =
        await databaseHarvestTicket.selectHarvestTicketCountUnUpload();
    notifyListeners();
  }

  getCountUnUploadedCollectionPoint() async {
    _countCollectionPoint = 0;
    _countCollectionPoint =
        await databaseCollectionPoint.selectCollectionPointCountUnUpload();
    notifyListeners();
  }

  getCountUnUploadedDeliveryOrder() async {
    _countDeliveryOrder = 0;
    _countDeliveryOrder =
        await DatabaseDeliveryOrder().selectDeliveryOrderCountUnUpload();
    notifyListeners();
  }
}
