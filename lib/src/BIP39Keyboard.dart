/*
BIP39Keyboard

onPress returns List<String>
onComplete returns List<String>

wordList=List<List<String>>;
ex
{
  "english"= ["abandon", "ability", "able", ...],
  "french"= ["abaisser", "abandon", "abdiquer", ...],
  "italian"= ["abaco", "abbaglio", "abbinato", ...],
  "spanish"= ["ábaco", "abdomen", "abeja", ...]
}


 */
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';

class BIP39Keyboard extends StatefulWidget {
  BIP39Keyboard({
    Key key,
    @required this.onPressed,
    @required this.onComplete,
    @required this.wordList,
    this.doneButtonMessage="Done",  //Allows changing language
  }): super(key: key);

  final Function onPressed;/// returns List<String>
  final Function onComplete;/// returns List<String>
  final Map<String, List<String>> wordList;
  final String doneButtonMessage;

  @override
  _BIP39Keyboard createState() => _BIP39Keyboard();
}

class _BIP39Keyboard extends State<BIP39Keyboard> {
  String _word="";
  List <String> _seed=[];
  BuildContext _context;

  String get seed=>(_seed.join(" ")+_word).trimRight();
  String get language{
    if (_languagePossible.length==0) return _languagePossible[0];
    if (_languagePossible.contains("english")) return "english";
    if (_languagePossible.length==0) return null;
    return _languagePossible[0];
  }



  //prefix widget. onPressed,onComplete,wordList,onEnter;
  @override
  initState() {
    checkPossibleLanguage();
    checkPossibleLetters();
    super.initState();
  }

  double _myWidth;
  @override
  Widget build(BuildContext context) {
    _context=context;
    _myWidth=MediaQuery.of(context).size.width;
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                predictKey(0),predictKey(1),predictKey(2),predictKey(3),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                smartKey("Q"),smartKey("W"),smartKey("E"),smartKey("R"),smartKey("T"),smartKey("Y"),smartKey("U"),smartKey("I"),smartKey("O"),smartKey("P"),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                smartKey("A"),smartKey("S"),smartKey("D"),smartKey("F"),smartKey("G"),smartKey("H"),smartKey("J"),smartKey("K"),smartKey("L"),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                smartKey("Z"),smartKey("X"),smartKey("C"),smartKey("V"),smartKey("B"),smartKey("N"),smartKey("M"),backKey(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget> [
                spaceKey(),doneKey(),
              ],
            ),
          ),
        ]
    );
  }


  //Letter Buttons
  List<String> _mostLikely=["","","",""];
  String _possible="";
  String _found="";
  List<String> _languagePossible;
  bool _validSeedFormat;

  void checkPossibleLanguage() {
    _languagePossible=[];
    widget.wordList.forEach((String language,List<String> words){
      bool allFound=true;
      _seed.forEach((word){
        if (!words.contains(word)) allFound=false;
      });
      if (allFound) _languagePossible.add(language);
    });
  }
  void removeInpossibleLanguage(String word) {
    List<String> toRemove=[];
    _languagePossible.forEach((String language){
      if (!widget.wordList[language].contains(word)) toRemove.add(language);
    });
    toRemove.forEach((language){
      _languagePossible.remove(language);
    });
  }
  void checkPossibleLetters(){
    int length=_word.length;
    String possible="";
    List<String> found=[];
    int maxFind=widget.wordList.length*4;
    String strFound="";


    //go through possible languages and see what letters are possible
    _languagePossible.forEach((String language) {
      widget.wordList[language].forEach((word) {
        String strippedPaddedWord=removeDiacritics(word + "                            ");
        if (strippedPaddedWord.substring(0, length) == _word) {
          possible += strippedPaddedWord[length];
          if (found.length<maxFind) found.add(word);
          if (word.length==_word.length) strFound=word;//handle if there is a shorter option but still valid letters
        }
      });
    });

    //remove duplicate found words(can happen because different languages may contain same words)
    found=found.toSet().toList();
    found.sort((a,b) {
      return a.compareTo(b);
    });

    //show prediction
    for (int i=0;i<4;i++) {
      if ((found.length<=i)||(_word.length<2)) {
        _mostLikely[i]="";
      } else {
        _mostLikely[i]=found[i];
      }
    }


    //If only 1 is possible then we set spacebar=to that word
    if (found.length==1) {
      possible = ""; //only 1 option so make found only option
      strFound=found[0];
    }

    //if one of found options has space then

    //update widget state
    setState(()=>_possible=possible);
    setState(()=>_found=strFound);
    setState(()=>_validSeedFormat=((_word=="")&&(_seed.length%3==0)&&(_seed.length>0)&&(_seed.length <= 24)));
  }
  Widget smartKey(String letter) {
    String lower=letter.toLowerCase();
    return MaterialButton(
      padding: const EdgeInsets.all(0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: _myWidth/10-4.0,
      child: Text("$letter",
          style: TextStyle(fontWeight: FontWeight.bold)),
      textColor: _possible.contains("$lower")?Theme.of(_context).textTheme.button.color : Theme.of(_context).buttonColor,
      color: Theme.of(_context).buttonColor,
      onPressed: () {
        if (_possible.contains("$lower")) {
          setState(() => _word += lower);
          checkPossibleLetters();
          widget.onPressed(_seed,_word);
        }
      },
    );
  }

  Widget backKey() {
    return MaterialButton(
      padding: const EdgeInsets.all(0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: _myWidth/5-2,
      child: Text("<-",
          style: TextStyle(fontWeight: FontWeight.bold)),
      textColor: ((_seed.length>0)||(_word!=""))?Theme.of(_context).textTheme.button.color : Theme.of(_context).buttonColor,
      color: Theme.of(_context).buttonColor,
      onPressed: () {
        if ((_seed.length>0)||(_word!="")) {
          if (_word=="") {
            _seed.removeLast();
          } else {
            _word = _word.substring(0,_word.length-1);
          }
        }
        checkPossibleLanguage();
        checkPossibleLetters();
        widget.onPressed(_seed,_word);
      },
    );
  }
  Widget predictKey(int index) {
    return MaterialButton(
      padding: const EdgeInsets.all(0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: _myWidth/4-10,
      child: Text("${_mostLikely[index]}",
          style: TextStyle(fontWeight: FontWeight.bold)),
      textColor: (_mostLikely[index]!="")?Theme.of(_context).textTheme.button.color : Theme.of(_context).buttonColor,
      color: Theme.of(_context).buttonColor,
      onPressed: () {
        if (_mostLikely[index]!="") {
          _seed.add(_mostLikely[index]);
          _word="";
          removeInpossibleLanguage(_mostLikely[index]);
          checkPossibleLetters();
          widget.onPressed(_seed,_word);
        }
      },
    );
  }
  Widget spaceKey() {
    return MaterialButton(
      padding: const EdgeInsets.all(0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: _myWidth*2/3-10,
      child: Text("$_found",
          style: TextStyle(fontWeight: FontWeight.bold)),
      textColor: (_found!="")?Theme.of(_context).textTheme.button.color : Theme.of(_context).buttonColor,
      color: Theme.of(_context).buttonColor,
      onPressed: () {
        if (_found!="") {
          _seed.add(_found);
          _word="";
          removeInpossibleLanguage(_found);
          checkPossibleLetters();
          widget.onPressed(_seed,_word);
        }
      },
    );
  }
  Widget doneKey() {
    return MaterialButton(
      padding: const EdgeInsets.all(0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: _myWidth/3-10,
      child: Text(widget.doneButtonMessage,
          style: TextStyle(fontWeight: FontWeight.bold)),
      textColor: _validSeedFormat?Theme.of(_context).textTheme.button.color : Theme.of(_context).buttonColor,
      color: Theme.of(_context).buttonColor,
      onPressed: (){
        if (_validSeedFormat) widget.onComplete(seed,language);
      },
    );
  }
}
