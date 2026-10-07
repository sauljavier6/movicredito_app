import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';
import '../../core/refresh/auto_refresh_state.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  @override State<DocumentsPage> createState()=>_DocumentsPageState();
}
class _DocumentsPageState extends State<DocumentsPage> with AutoRefreshState<DocumentsPage>{
  final auth=AuthService(); List<dynamic> contracts=[]; bool loading=true; String? error;
  @override void initState(){super.initState();_load();}
  @override Future<void> refreshData()=>_load();
  Future<void> _load() async {try{final d=await auth.documents();if(mounted)setState((){contracts=(d['contracts'] as List?)??[];loading=false;error=null;});}on ApiException catch(e){if(mounted)setState((){error=e.message;loading=false;});}catch(_){if(mounted)setState((){error='No pudimos cargar tus documentos.';loading=false;});}}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Contrato y documentos',style:TextStyle(fontWeight:FontWeight.w800))),
    body:loading?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Padding(padding:const EdgeInsets.all(24),child:Text(error!))):contracts.isEmpty
      ?const Center(child:Padding(padding:EdgeInsets.all(24),child:Text('No hay contratos disponibles para tu cuenta.',textAlign:TextAlign.center)))
      :ListView.builder(padding:const EdgeInsets.all(20),itemCount:contracts.length,itemBuilder:(context,i){final item=Map<String,dynamic>.from(contracts[i] as Map);return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(child:ListTile(
        contentPadding:const EdgeInsets.all(16),
        leading:Container(width:48,height:48,decoration:BoxDecoration(color:const Color(0xFFEEF4FF),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.description_outlined,color:Color(0xFF175CD3))),
        title:Text('Contrato v${item['version']}',style:const TextStyle(fontWeight:FontWeight.w800)),
        subtitle:Text('${_status(item['status'])} · ${_date(item['acceptedAt']??item['createdAt'])}'),
        trailing:const Icon(Icons.chevron_right_rounded),
        onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>_ContractDetail(contract:item))),
      )));}),
  );
}
class _ContractDetail extends StatelessWidget{
  const _ContractDetail({required this.contract}); final Map<String,dynamic> contract;
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text('Contrato v${contract['version']}')),
    body:SelectionArea(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(20,12,20,40),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Icon(Icons.verified_outlined,color:Color(0xFF175CD3)),const SizedBox(width:8),Text(_status(contract['status']),style:const TextStyle(fontWeight:FontWeight.w800))]),
      const SizedBox(height:20),
      Text((contract['contractText']??'Documento sin contenido.').toString(),style:const TextStyle(height:1.55,fontSize:14)),
    ]))),
  );
}
String _date(dynamic v){final d=DateTime.tryParse(v?.toString()??'')?.toLocal();return d==null?'Sin fecha':DateFormat('dd/MM/yyyy').format(d);}
String _status(dynamic v)=>v=='accepted'?'Aceptado':v=='generated'?'Generado':(v??'').toString();
