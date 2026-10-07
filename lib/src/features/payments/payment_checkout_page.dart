import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_service.dart';

class PaymentCheckoutPage extends StatefulWidget {
  const PaymentCheckoutPage({super.key});
  @override State<PaymentCheckoutPage> createState()=>_PaymentCheckoutPageState();
}
class _PaymentCheckoutPageState extends State<PaymentCheckoutPage>{
  final auth=AuthService();
  Map<String,dynamic>? checkout;
  bool loading=true, syncing=false;
  String? error, message;

  @override void initState(){super.initState();_create();}

  Future<void> _create() async{
    try{
      final data=await auth.createPaymentCheckout();
      if(mounted)setState((){checkout=data;loading=false;error=null;});
    }on ApiException catch(e){if(mounted)setState((){error=e.message;loading=false;});}
    catch(_){if(mounted)setState((){error='No pudimos preparar tu pago.';loading=false;});}
  }

  Future<void> _open() async{
    final url=checkout?['paymentUrl']?.toString()??'';
    final uri=Uri.tryParse(url);
    if(uri==null||!await launchUrl(uri,mode:LaunchMode.externalApplication)){
      if(mounted)setState(()=>error='No fue posible abrir Mercado Pago.');
    }
  }

  Future<void> _sync() async{
    final id=checkout?['checkoutId']?.toString();
    if(id==null)return;
    setState((){syncing=true;message=null;error=null;});
    try{
      final data=await auth.syncPaymentCheckout(id);
      if(!mounted)return;
      final approved=data['status']=='approved';
      setState((){syncing=false;message=(data['message']??'').toString();});
      if(approved){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Pago confirmado y aplicado.')));
        await Future<void>.delayed(const Duration(milliseconds:700));
        if(mounted)Navigator.pop(context,true);
      }
    }on ApiException catch(e){if(mounted)setState((){syncing=false;error=e.message;});}
    catch(_){if(mounted)setState((){syncing=false;error='No pudimos verificar el pago.';});}
  }

  @override Widget build(BuildContext context){
    final installment=checkout?['installment'] as Map<String,dynamic>?;
    return Scaffold(
      appBar:AppBar(title:const Text('Realizar pago',style:TextStyle(fontWeight:FontWeight.w800))),
      body:loading?const Center(child:CircularProgressIndicator()):error!=null&&checkout==null
        ?Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Text(error!,textAlign:TextAlign.center),const SizedBox(height:16),FilledButton(onPressed:(){setState(()=>loading=true);_create();},child:const Text('Reintentar'))])))
        :ListView(padding:const EdgeInsets.all(20),children:[
          Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Pago a realizar',style:TextStyle(color:Color(0xFF667085))),
            const SizedBox(height:5),
            Text(_money(checkout?['amount']),style:const TextStyle(fontSize:32,fontWeight:FontWeight.w800)),
            const SizedBox(height:18),
            _row('Mensualidad','#${installment?['number']??'—'}'),
            _row('Fecha límite',_date(installment?['dueDate'])),
            _row('Proveedor','Mercado Pago'),
          ]))),
          const SizedBox(height:18),
          FilledButton.icon(onPressed:_open,icon:const Icon(Icons.open_in_new_rounded),label:const Text('Continuar a Mercado Pago'),style:FilledButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:16))),
          const SizedBox(height:12),
          OutlinedButton.icon(onPressed:syncing?null:_sync,icon:syncing?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.refresh_rounded),label:Text(syncing?'Verificando...':'Ya pagué, verificar pago'),style:OutlinedButton.styleFrom(padding:const EdgeInsets.symmetric(vertical:16))),
          if(message!=null)...[const SizedBox(height:16),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFECFDF3),borderRadius:BorderRadius.circular(14)),child:Text(message!,style:const TextStyle(color:Color(0xFF027A48),fontWeight:FontWeight.w600)))],
          if(error!=null)...[const SizedBox(height:16),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFFEF3F2),borderRadius:BorderRadius.circular(14)),child:Text(error!,style:const TextStyle(color:Color(0xFFB42318))))],
          const SizedBox(height:18),
          const Text('El pago solo se aplicará a tu crédito después de que Mercado Pago lo reporte como aprobado. No cierres esta pantalla hasta terminar el proceso.',style:TextStyle(color:Color(0xFF667085),fontSize:12,height:1.45)),
        ]),
    );
  }
  Widget _row(String a,String b)=>Padding(padding:const EdgeInsets.only(top:10),child:Row(children:[Expanded(child:Text(a,style:const TextStyle(color:Color(0xFF667085)))),Text(b,style:const TextStyle(fontWeight:FontWeight.w700))]));
}
String _money(dynamic v)=>NumberFormat.currency(locale:'es_MX',symbol:'\$',decimalDigits:2).format(num.tryParse(v?.toString()??'')??0);
String _date(dynamic v){final d=DateTime.tryParse(v?.toString()??'');return d==null?'—':DateFormat('dd/MM/yyyy').format(d);}
