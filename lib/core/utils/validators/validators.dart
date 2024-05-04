


class Validator{


  static String? personNameValidator(String? value){

    if (value == null || value.isEmpty) {
      return 'Please mention a name!';
    }
    return null;
  }


}