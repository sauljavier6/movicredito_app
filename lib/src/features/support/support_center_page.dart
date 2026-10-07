import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../auth/auth_service.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});
  @override State<SupportCenterPage> createState()=>_SupportCenterPageState();
}
class _SupportCenterPageState extends State<SupportCenterPage>{
  final auth=AuthService(); List<dynamic> tickets=[]; List<dynamic> notifications=[]; bool loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async{try{final r=await Future.wait([auth.supportTickets(),auth.notifications()]);if(mounted)setState((){tickets=(r[0]['items'] as List?)??[];notifications=(r[1]['items'] as List?)??[];loading=false;});}catch(_){if(mounted)setState(()=>loading=false);}}
  Future<void> _newTicket() async{
    final result=await showModalBottomSheet<Map<String,String>>(context:context,isScrollControlled:true,builder:(_)=>const _NewTicketSheet());
    if(result==null)return;
    await auth.createSupportTicket(result['subject']!,result['category']!,result['message']!); await _load();
  }
  @override Widget build(BuildContext context)=>DefaultTabController(length:2,child:Scaffold(
    appBar:AppBar(title:const Text('Centro de ayuda',style:TextStyle(fontWeight:FontWeight.w800)),bottom:const TabBar(tabs:[Tab(text:'Soporte'),Tab(text:'Notificaciones')])),
    floatingActionButton:FloatingActionButton.extended(onPressed:_newTicket,icon:const Icon(Icons.add_comment_outlined),label:const Text('Nueva consulta')),
    body:loading?const Center(child:CircularProgressIndicator()):TabBarView(children:[
      RefreshIndicator(onRefresh:_load,child:tickets.isEmpty?ListView(children:const [SizedBox(height:180),Center(child:Text('No tienes consultas de soporte.'))]):ListView.builder(padding:const EdgeInsets.all(16),itemCount:tickets.length,itemBuilder:(context,i){final t=Map<String,dynamic>.from(tickets[i] as Map);return Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(contentPadding:const EdgeInsets.all(16),leading:const CircleAvatar(child:Icon(Icons.support_agent_rounded)),title:Text(t['subject']?.toString()??'',style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${_status(t['status'])} · ${_date(t['lastMessageAt']??t['createdAt'])}'),trailing:(t['unread']??0)>0?Badge(label:Text('${t['unread']}')):const Icon(Icons.chevron_right),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>SupportThreadPage(ticket:t))).then((_)=>_load()));})),
      RefreshIndicator(onRefresh:_load,child:notifications.isEmpty?ListView(children:const [SizedBox(height:180),Center(child:Text('No tienes notificaciones.'))]):ListView.builder(padding:const EdgeInsets.all(16),itemCount:notifications.length,itemBuilder:(context,i){final n=Map<String,dynamic>.from(notifications[i] as Map);return Card(margin:const EdgeInsets.only(bottom:10),child:ListTile(leading:Icon(n['read']==true?Icons.notifications_none:Icons.notifications_active_rounded,color:const Color(0xFF175CD3)),title:Text(n['title']?.toString()??'',style:TextStyle(fontWeight:n['read']==true?FontWeight.w600:FontWeight.w800)),subtitle:Text('${n['body']??''}\n${_date(n['createdAt'])}')));}))
    ]),
  ));
}
class SupportThreadPage extends StatefulWidget{const SupportThreadPage({super.key,required this.ticket});final Map<String,dynamic> ticket;@override State<SupportThreadPage> createState()=>_SupportThreadPageState();}
class _SupportThreadPageState extends State<SupportThreadPage>{
 final auth=AuthService();final input=TextEditingController();List<dynamic> messages=[];bool loading=true,sending=false;
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final d=await auth.supportMessages(widget.ticket['id'].toString());if(mounted)setState((){messages=(d['messages'] as List?)??[];loading=false;});}
 Future<void> _send()async{final text=input.text.trim();if(text.isEmpty)return;setState(()=>sending=true);await auth.replySupport(widget.ticket['id'].toString(),text);input.clear();await _load();if(mounted)setState(()=>sending=false);}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.ticket['subject'].toString())),body:Column(children:[Expanded(child:loading?const Center(child:CircularProgressIndicator()):ListView.builder(padding:const EdgeInsets.all(16),itemCount:messages.length,itemBuilder:(context,i){final m=Map<String,dynamic>.from(messages[i] as Map);final mine=m['senderType']=='customer';return Align(alignment:mine?Alignment.centerRight:Alignment.centerLeft,child:Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.symmetric(horizontal:14,vertical:11),constraints:const BoxConstraints(maxWidth:300),decoration:BoxDecoration(color:mine?const Color(0xFF175CD3):Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m['message'].toString(),style:TextStyle(color:mine?Colors.white:const Color(0xFF101828))),const SizedBox(height:4),Text(_date(m['createdAt']),style:TextStyle(fontSize:10,color:mine?Colors.white70:const Color(0xFF98A2B3)))])));})),SafeArea(child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[Expanded(child:TextField(controller:input,minLines:1,maxLines:4,decoration:const InputDecoration(hintText:'Escribe un mensaje...'))),const SizedBox(width:8),IconButton.filled(onPressed:sending?null:_send,icon:const Icon(Icons.send_rounded))])))]));
}
class _NewTicketSheet extends StatefulWidget{const _NewTicketSheet();@override State<_NewTicketSheet> createState()=>_NewTicketSheetState();}
class _NewTicketSheetState extends State<_NewTicketSheet>{final subject=TextEditingController(),message=TextEditingController();String category='general';@override Widget build(BuildContext context)=>Padding(padding:EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).viewInsets.bottom+24),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Nueva consulta',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const SizedBox(height:16),DropdownButtonFormField<String>(initialValue:category,items:const [DropdownMenuItem(value:'general',child:Text('Pregunta general')),DropdownMenuItem(value:'payment',child:Text('Pago')),DropdownMenuItem(value:'credit',child:Text('Crédito')),DropdownMenuItem(value:'device',child:Text('Equipo'))],onChanged:(v)=>setState(()=>category=v??'general')),const SizedBox(height:12),TextField(controller:subject,decoration:const InputDecoration(labelText:'Asunto')),const SizedBox(height:12),TextField(controller:message,maxLines:4,decoration:const InputDecoration(labelText:'¿En qué podemos ayudarte?')),const SizedBox(height:16),FilledButton(onPressed:()=>Navigator.pop(context,{'subject':subject.text.trim(),'category':category,'message':message.text.trim()}),child:const Text('Enviar consulta'))]));}
String _status(dynamic v)=>v=='open'?'Abierto':v=='in_progress'?'En atención':v=='resolved'?'Resuelto':'Cerrado';
String _date(dynamic v){final d=DateTime.tryParse(v?.toString()??'')?.toLocal();return d==null?'':DateFormat('dd/MM/yyyy HH:mm').format(d);}
