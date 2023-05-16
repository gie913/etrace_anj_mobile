import 'dart:convert';

import 'package:e_trace_app/database_local/database_entity.dart';
import 'package:e_trace_app/model/agents.dart';
import 'package:e_trace_app/model/collection_point.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabaseAgent {

  Future<List<Agents>> getAgentList() async {
    Database db = await DatabaseHelper().database;
    List<Agents> listAgent = [];
    var agentMapList = await db.query(TABLE_AGENT);
    if (agentMapList.isNotEmpty) {
      for (var i = 0; i < agentMapList.length; i++) {
        var agentsJson = json.decode(json.encode(agentMapList[i]));
        Agents agents = Agents.fromJson(agentsJson);
        listAgent.add(agents);
        print("getAgentList: Success $agents");
      }
    } else {
     print("getAgentList: Empty");
    }
    return listAgent;
  }

  Future<Agents> getAgentByID(CollectionPoint object) async {
    Database db = await DatabaseHelper().database;
    Agents agents = Agents();
    var mapList = await db.query(TABLE_AGENT,
        where: '$AGENT_ASCEND_CODE=?', whereArgs: [object.ascendAgentCode]);
    if (mapList.isNotEmpty) {
      for (int i = 0; i < mapList.length; i++) {
        agents = Agents.fromJson(mapList[i]);
      }
    } else {
      print("getAgentByID: Empty");
    }
    return agents;
  }
}
