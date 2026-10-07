import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});
  @override State<DevicePage> createState() => _DevicePageState();
}
class _DevicePageState extends State<DevicePage> {
  final auth = AuthService();
  Map<String,dynamic>? device;
  bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { try { final d=await auth.summary(); if(mounted)setState((){device=d['device'] as Map<String,dynamic>?;loading=false;}); } catch(_){if(mounted)setState(()=>loading=false);} }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar: AppBar(title: const Text('Mi equipo',style:TextStyle(fontWeight:FontWeight.w800))),
    body: loading?const Center(child:CircularProgressIndicator()):device==null
      ? const Center(child:Padding(padding:EdgeInsets.all(24),child:Text('No hay un equipo asociado a tu crédito.',textAlign:TextAlign.center)))
      : ListView(padding:const EdgeInsets.all(20),children:[
          Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(children:[
            Container(width:82,height:82,decoration:BoxDecoration(color:const Color(0xFFEEF4FF),borderRadius:BorderRadius.circular(24)),child:const Icon(Icons.smartphone_rounded,size:44,color:Color(0xFF175CD3))),
            const SizedBox(height:16),
            Text([device!['brand'],device!['model']].where((e)=>e!=null&&e.toString().isNotEmpty).join(' '),style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800),textAlign:TextAlign.center),
            const SizedBox(height:20),
            _row('Almacenamiento',device!['storage']),
            _row('Color',device!['color']),
            _row('Estado',device!['status']),
            _row('Administración',device!['managementStatus']),
          ]))),
        ]),
  );
  Widget _row(String label,dynamic value)=>Padding(padding:const EdgeInsets.symmetric(vertical:9),child:Row(children:[Expanded(child:Text(label,style:const TextStyle(color:Color(0xFF667085)))),Text((value??'—').toString(),style:const TextStyle(fontWeight:FontWeight.w700))]));
}
