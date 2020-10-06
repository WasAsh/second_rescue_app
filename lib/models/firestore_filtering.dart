import 'package:cloud_firestore/cloud_firestore.dart';



class FilterService{
  filterByCity( String filterValue ){
    return Firestore.instance
        .collection('issues')
        .where('city' ,
      isEqualTo: filterValue)
        .getDocuments() ;
  }
}