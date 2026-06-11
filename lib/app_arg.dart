import 'package:args/args.dart';

ArgParser get appAargs {
  final parser = ArgParser();
  parser.addFlag(
    'other-cache',
    abbr: 'c', // စာလုံးတစ်လုံးတည်းပဲ သုံးရပါမယ် (ဥပမာ 'c' သို့မဟုတ် 'o')
    negatable: false, // true/false ကို --no- အနေနဲ့ မသုံးချင်လို့ false ထားတာပါ
    help: 'Include Other Cache (default=false)',
  );
  parser.addFlag(
    'include-empty-cache-project',
    abbr: 'e',
    negatable: false,
    help: 'Inclue Empty Cache Project (default=false)',
  );

  parser.addFlag('scan', abbr: 's', negatable: false, help: 'Scan Project');

  // help
  parser.addFlag('help', abbr: 'h', negatable: false, help: 'Can Use Command.');

  return parser;
}
