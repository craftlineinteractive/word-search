// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

class WordDef {
  final String word;
  final String meaning;
  final String example;

  const WordDef(this.word, this.meaning, this.example);

  Map<String, dynamic> toJson() => {
    'word': word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), ''),
    'meaning': meaning,
    'example': example,
  };
}

class ChapterDef {
  final int id;
  final String key;
  final String title;
  final String iconAsset;
  final int themeColor;
  final List<WordDef> shortWords;
  final List<WordDef> mediumWords;
  final List<WordDef> longWords;

  const ChapterDef({
    required this.id,
    required this.key,
    required this.title,
    required this.iconAsset,
    required this.themeColor,
    required this.shortWords,
    required this.mediumWords,
    required this.longWords,
  });
}

void main() {
  final List<ChapterDef> chapters = _buildAll30Chapters();

  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }

  int totalLevels = 0;
  int totalWords = 0;

  for (var ch in chapters) {
    final List<List<WordDef>> levelSets = _generateVariedLevelSets(
      shortWords: ch.shortWords,
      mediumWords: ch.mediumWords,
      longWords: ch.longWords,
      levelCount: 35,
    );

    List<Map<String, dynamic>> levelsJson = [];
    int lvlNum = 1;

    for (var wordSet in levelSets) {
      int gridRows = 9;
      int gridCols = 9;
      String difficulty = 'normal';

      if (lvlNum >= 25) {
        gridRows = 14;
        gridCols = 14;
        difficulty = 'expert';
      } else if (lvlNum >= 18) {
        gridRows = 13;
        gridCols = 13;
        difficulty = 'hard';
      } else if (lvlNum >= 10) {
        gridRows = 11;
        gridCols = 11;
        difficulty = 'medium';
      } else {
        gridRows = 9;
        gridCols = 9;
        difficulty = 'normal';
      }

      int maxWordLenInSet = 0;
      for (var w in wordSet) {
        final cleanLen = w.word.replaceAll(RegExp(r'[^A-Z]'), '').length;
        if (cleanLen > maxWordLenInSet) {
          maxWordLenInSet = cleanLen;
        }
      }

      // Ensure grid lines strictly exceed longest word length so words never span edge-to-edge
      if (gridRows <= maxWordLenInSet) {
        gridRows = maxWordLenInSet + 2;
        gridCols = maxWordLenInSet + 2;
      }

      levelsJson.add({
        'levelNumber': lvlNum,
        'title': '${ch.title} Level $lvlNum',
        'gridRows': gridRows,
        'gridCols': gridCols,
        'difficulty': difficulty,
        'words': wordSet.map((w) => w.toJson()).toList(),
      });

      totalWords += wordSet.length;
      lvlNum++;
    }

    totalLevels += levelsJson.length;

    final chapterData = {
      'id': ch.id,
      'key': ch.key,
      'title': ch.title,
      'iconAsset': ch.iconAsset,
      'themeColor': ch.themeColor,
      'levels': levelsJson,
    };

    String filename =
        'chapter_${ch.id.toString().padLeft(2, '0')}_${ch.key}.json';
    File file = File('assets/data/$filename');
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(chapterData),
    );
    print('Generated $filename with ${levelsJson.length} distinct levels.');
  }

  print('\n========================================');
  print('Total Chapters: ${chapters.length}');
  print('Total Levels: $totalLevels (35 levels per chapter x 30 chapters)');
  print('Total Words: $totalWords with definitions & examples');
  print('========================================\n');
}

List<List<WordDef>> _generateVariedLevelSets({
  required List<WordDef> shortWords,
  required List<WordDef> mediumWords,
  required List<WordDef> longWords,
  required int levelCount,
}) {
  List<List<WordDef>> result = [];

  int shortIdx = 0;
  int medIdx = 0;
  int longIdx = 0;

  for (int lvl = 1; lvl <= levelCount; lvl++) {
    List<WordDef> levelWords = [];

    int numShort;
    int numMed;
    int numLong;

    if (lvl <= 9) {
      // Levels 1-9: 9x9 Grid (8 words: 5 short + 3 medium)
      numShort = 5;
      numMed = 3;
      numLong = 0;
    } else if (lvl <= 17) {
      // Levels 10-17: 11x11 Grid (9 words: 3 short + 4 medium + 2 long)
      numShort = 3;
      numMed = 4;
      numLong = 2;
    } else if (lvl <= 24) {
      // Levels 18-24: 13x13 Grid (11 words: 2 short + 5 medium + 4 long)
      numShort = 2;
      numMed = 5;
      numLong = 4;
    } else {
      // Levels 25-35: 14x14 Grid (13 words: 2 short + 5 medium + 6 long)
      numShort = 2;
      numMed = 5;
      numLong = 6;
    }

    // Add short words
    for (int s = 0; s < numShort; s++) {
      levelWords.add(shortWords[(shortIdx + s) % shortWords.length]);
    }
    shortIdx = (shortIdx + numShort) % shortWords.length;

    // Add medium words
    for (int m = 0; m < numMed; m++) {
      levelWords.add(mediumWords[(medIdx + m) % mediumWords.length]);
    }
    medIdx = (medIdx + numMed) % mediumWords.length;

    // Add long words
    for (int l = 0; l < numLong; l++) {
      levelWords.add(longWords[(longIdx + l) % longWords.length]);
    }
    longIdx = (longIdx + numLong) % longWords.length;

    // Ensure no duplicates within the same level
    final seen = <String>{};
    final uniqueLevelWords = <WordDef>[];
    for (var w in levelWords) {
      final key = w.word.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueLevelWords.add(w);
      }
    }

    result.add(uniqueLevelWords);
  }

  return result;
}

List<ChapterDef> _buildAll30Chapters() {
  return [
    // 1. Food
    ChapterDef(
      id: 1,
      key: 'food',
      title: 'Food',
      iconAsset: 'assets/chapter_images/food.png',
      themeColor: 0xFFFF5722,
      shortWords: const [
        WordDef(
          'TACO',
          'A Mexican dish of a folded tortilla with savory filling',
          'Spicy beef taco with salsa.',
        ),
        WordDef(
          'SOUP',
          'A liquid dish made by boiling ingredients in broth',
          'Hot chicken noodle soup on a rainy day.',
        ),
        WordDef(
          'BREAD',
          'Staple food made of flour and water and baked',
          'Freshly baked sourdough artisan bread.',
        ),
        WordDef(
          'APPLE',
          'A crisp round fruit of a tree of the rose family',
          'Sweet red honeycrisp apple.',
        ),
        WordDef(
          'MANGO',
          'A tropical stone fruit with sweet juicy flesh',
          'Chilled mango slices in summer.',
        ),
        WordDef(
          'TOAST',
          'Sliced bread browned on both sides by heat',
          'Crispy golden buttered toast.',
        ),
        WordDef(
          'PIZZA',
          'A baked flat disc of dough topped with sauce and cheese',
          'Thin crust margherita pizza.',
        ),
        WordDef(
          'CHIPS',
          'Thin slices of potato fried or baked until crisp',
          'Crunchy salted potato chips.',
        ),
        WordDef(
          'RICE',
          'The starchy seeds of an edible cereal grass',
          'Steamed fragrant jasmine rice.',
        ),
        WordDef(
          'STEAK',
          'High quality cut of beef cooked to perfection',
          'Medium-rare grilled ribeye steak.',
        ),
        WordDef(
          'SUSHI',
          'Japanese dish of seasoned rice with raw seafood',
          'Fresh salmon and tuna sushi.',
        ),
        WordDef(
          'BACON',
          'Cured pork belly strips fried until crisp',
          'Smoky crispy breakfast bacon.',
        ),
        WordDef(
          'DONUT',
          'A sweet fried ring-shaped dough pastry',
          'Glazed strawberry frosted donut.',
        ),
        WordDef(
          'SALAD',
          'A dish of mixed raw vegetables and dressing',
          'Fresh garden salad with feta.',
        ),
        WordDef(
          'PASTA',
          'Italian dough shaped into tubes, strands, or bows',
          'Penne pasta tossed in marinara.',
        ),
        WordDef(
          'CURRY',
          'A dish cooked in a spiced aromatic sauce',
          'Fragrant chicken tikka masala curry.',
        ),
        WordDef(
          'CREPE',
          'A very thin pancake served sweet or savory',
          'French chocolate banana crepe.',
        ),
        WordDef(
          'BAGEL',
          'A dense ring-shaped bread roll',
          'Toasted bagel with herb cream cheese.',
        ),
        WordDef(
          'OLIVE',
          'Small oval fruit cured in brine or pressed for oil',
          'Kalamata black olives on a salad.',
        ),
        WordDef(
          'HONEY',
          'A sweet sticky fluid made by honeybees',
          'Golden raw honey drizzled on oats.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'BURGER',
          'A cooked patty inside a sliced round bun',
          'Juicy grilled cheddar cheeseburger.',
        ),
        WordDef(
          'CHEESE',
          'Food made from the pressed curds of milk',
          'Aged gouda and cheddar cheese.',
        ),
        WordDef(
          'MUFFIN',
          'A small domed quick bread baked in a cup',
          'Warm blueberry crumble muffin.',
        ),
        WordDef(
          'BUTTER',
          'A dairy spread made by churning fresh cream',
          'Rich creamy salted table butter.',
        ),
        WordDef(
          'NOODLE',
          'Long thin strips of dough cooked in boiling water',
          'Hand-pulled ramen wheat noodles.',
        ),
        WordDef(
          'OMELET',
          'Dish of beaten eggs folded around savory fillings',
          'Fluffy mushroom and spinach omelet.',
        ),
        WordDef(
          'PANCAKE',
          'Thin flat round cake fried on a hot griddle',
          'Fluffy buttermilk pancake stack.',
        ),
        WordDef(
          'POPCORN',
          'Heated corn kernels that puff up into light snacks',
          'Cinema buttery crunchy popcorn.',
        ),
        WordDef(
          'SAUSAGE',
          'Minced seasoned meat enclosed in a cylindrical casing',
          'Sizzling German bratwurst sausage.',
        ),
        WordDef(
          'AVOCADO',
          'Pear-shaped fruit with creamy green rich flesh',
          'Fresh smashed avocado on toast.',
        ),
        WordDef(
          'BROCCOLI',
          'Edible green plant with dense florets',
          'Steamed broccoli florets with lemon.',
        ),
        WordDef(
          'CARROT',
          'Tapering orange root vegetable eaten raw or cooked',
          'Sweet crunchy raw baby carrots.',
        ),
        WordDef(
          'SPINACH',
          'Nutritious green leafy vegetable rich in iron',
          'Baby spinach salad with walnuts.',
        ),
        WordDef(
          'TOMATO',
          'Glossy red edible berry used widely in cooking',
          'Sun-ripened sweet cherry tomatoes.',
        ),
        WordDef(
          'GARLIC',
          'Pungent bulb consisting of cloves used for flavor',
          'Roasted garlic cloves in olive oil.',
        ),
        WordDef(
          'WAFFLE',
          'Crisp batter cake baked in a patterned iron',
          'Belgian waffle topped with berries.',
        ),
        WordDef(
          'BROWNIE',
          'Rich chewy baked chocolate square',
          'Fudgy dark chocolate walnut brownie.',
        ),
        WordDef(
          'COOKIE',
          'Small sweet baked confection',
          'Chewy chocolate chip cookie.',
        ),
        WordDef(
          'LASAGNA',
          'Baked layers of wide pasta, meat sauce, and cheese',
          'Hearty homemade lasagna slice.',
        ),
        WordDef(
          'RISOTTO',
          'Creamy Italian rice dish cooked slowly in broth',
          'Saffron risotto with parmesan.',
        ),
      ],
      longWords: const [
        WordDef(
          'SPAGHETTI',
          'Long, thin cylindrical pasta of Italian origin',
          'Spaghetti tossed with garlic and oil.',
        ),
        WordDef(
          'CROISSANT',
          'Flaky, buttery crescent-shaped French pastry',
          'Freshly baked flaky croissant.',
        ),
        WordDef(
          'CHOCOLATE',
          'Sweet food prepared from roasted cacao seeds',
          'Decadent 70 percent dark chocolate.',
        ),
        WordDef(
          'PINEAPPLE',
          'Large tropical fruit with sweet fibrous yellow pulp',
          'Fresh tropical pineapple chunks.',
        ),
        WordDef(
          'SANDWICH',
          'Filling placed between two slices of bread',
          'Toasted sourdough club sandwich.',
        ),
        WordDef(
          'BLUEBERRY',
          'Small sweet antioxidant-rich blue berry',
          'Wild blueberries on morning yogurt.',
        ),
        WordDef(
          'RASPBERRY',
          'Delicate tart red aggregate berry',
          'Fresh raspberries with vanilla cream.',
        ),
        WordDef(
          'GUACAMOLE',
          'Mexican dip made from mashed avocados and spices',
          'Tortilla chips with zesty guacamole.',
        ),
        WordDef(
          'MUSHROOM',
          'Fleshy fungal fruiting body with a domed cap',
          'Sautéed portobello button mushrooms.',
        ),
        WordDef(
          'ASPARAGUS',
          'Tender green edible shoots of the lily family',
          'Roasted asparagus spears with garlic.',
        ),
        WordDef(
          'CUCUMBER',
          'Long crisp cylindrical fruit with green skin',
          'Sliced cool cucumber in tzatziki.',
        ),
        WordDef(
          'MARMALADE',
          'Preserve made from the juice and peel of citrus',
          'Seville orange bitter marmalade.',
        ),
        WordDef(
          'TIRAMISU',
          'Italian dessert of coffee-soaked ladyfingers and cream',
          'Cocoa-dusted creamy tiramisu.',
        ),
        WordDef(
          'PISTACHIO',
          'Edible pale green nut encased in a hard beige shell',
          'Roasted salted pistachio nuts.',
        ),
        WordDef(
          'MACARONI',
          'Dry pasta formed into small curved tubes',
          'Creamy baked macaroni and cheese.',
        ),
        WordDef(
          'CASSEROLE',
          'Baked dish of meat and vegetables cooked slowly in oven',
          'Cheesy broccoli potato casserole.',
        ),
        WordDef(
          'ARTICHOKE',
          'Edible thistle head with tender heart and leaves',
          'Steamed whole globe artichoke.',
        ),
        WordDef(
          'DUMPLINGS',
          'Small savory balls of dough steamed or fried',
          'Crispy pan-fried pork dumplings.',
        ),
        WordDef(
          'PEPPERONI',
          'Spicy dry cured sausage made from beef and pork',
          'Wood-fired pepperoni slice.',
        ),
        WordDef(
          'WATERMELON',
          'Large sweet melon with green rind and red juicy pulp',
          'Refreshing cold watermelon slices.',
        ),
        WordDef(
          'STRAWBERRY',
          'Juicy sweet red heart-shaped fruit',
          'Strawberries with whipped cream.',
        ),
        WordDef(
          'CAULIFLOWER',
          'Vegetable with a compact head of white florets',
          'Spiced roasted cauliflower bites.',
        ),
        WordDef(
          'POMEGRANATE',
          'Red fruit filled with hundreds of juicy seeds',
          'Ruby red pomegranate arils.',
        ),
        WordDef(
          'MAYONNAISE',
          'Creamy emulsion of egg yolk, oil, and vinegar',
          'Creamy garlic herb mayonnaise.',
        ),
        WordDef(
          'QUESADILLA',
          'Toasted tortilla filled with melted cheese',
          'Crispy grilled chicken quesadilla.',
        ),
        WordDef(
          'BREADSTICKS',
          'Long thin sticks of crisp baked bread',
          'Garlic parmesan warm breadsticks.',
        ),
        WordDef(
          'PROSCIUTTO',
          'Dry-cured Italian ham served in paper-thin slices',
          'Prosciutto wrapped around melon.',
        ),
        WordDef(
          'CANNELLONI',
          'Large cylindrical pasta tubes filled with ricotta',
          'Baked spinach ricotta cannelloni.',
        ),
        WordDef(
          'BRUSCHETTA',
          'Grilled bread rubbed with garlic and tomato topping',
          'Crispy tomato basil bruschetta.',
        ),
        WordDef(
          'MINESTRONE',
          'Thick Italian vegetable soup with beans and pasta',
          'Hearty winter minestrone soup.',
        ),
        WordDef(
          'MOZZARELLA',
          'Soft mild white Italian cheese',
          'Fresh buffalo mozzarella balls.',
        ),
        WordDef(
          'VINAIGRETTE',
          'Dressing made of oil, vinegar, and seasonings',
          'Tangy lemon herb vinaigrette.',
        ),
        WordDef(
          'BUTTERMILK',
          'Slightly acidic liquid used in baking fluffy pastries',
          'Fluffy buttermilk pancakes.',
        ),
        WordDef(
          'GINGERBREAD',
          'Spiced baked treat flavored with ginger and molasses',
          'Holiday gingerbread cookie man.',
        ),
        WordDef(
          'SAUERKRAUT',
          'Fermented finely shredded raw cabbage',
          'Tangy German style sauerkraut.',
        ),
      ],
    ),

    // 2. Holiday
    ChapterDef(
      id: 2,
      key: 'holiday',
      title: 'Holiday',
      iconAsset: 'assets/chapter_images/holiday.png',
      themeColor: 0xFF00BCD4,
      shortWords: const [
        WordDef(
          'SNOW',
          'Water vapor frozen into ice crystals',
          'White snow blanket on the ground.',
        ),
        WordDef(
          'GIFT',
          'A present given to someone on a special day',
          'Nicely wrapped birthday gift.',
        ),
        WordDef(
          'TREE',
          'Evergreen fir decorated with festive lights',
          'Glittering pine holiday tree.',
        ),
        WordDef(
          'STAR',
          'Bright glowing object placed on top of trees',
          'Shining gold tree topper star.',
        ),
        WordDef(
          'BELL',
          'Metal instrument that rings a clear tone',
          'Silver bells jingle in the snow.',
        ),
        WordDef(
          'CARD',
          'Greeting sent to family and friends',
          'Handwritten holiday greeting card.',
        ),
        WordDef(
          'YULE',
          'The winter festival and celebration',
          'Lighting the festive yule log.',
        ),
        WordDef(
          'PINE',
          'Evergreen tree with needle leaves',
          'Scent of fresh pine branches.',
        ),
        WordDef(
          'TRIP',
          'A journey taken for leisure or vacation',
          'Exciting winter holiday road trip.',
        ),
        WordDef(
          'REST',
          'Time spent relaxing and recovering',
          'Peaceful holiday afternoon rest.',
        ),
        WordDef(
          'CAMP',
          'Outdoor adventure living in tents or huts',
          'Winter camping in the woods.',
        ),
        WordDef(
          'TOUR',
          'Sightseeing trip around memorable landmarks',
          'Guided historical walking tour.',
        ),
        WordDef(
          'WARM',
          'Comfortable moderate heat',
          'Warm fire crackling in the hearth.',
        ),
        WordDef(
          'COZY',
          'Comfortable, warm, and inviting feeling',
          'Cozy cabin with soft blankets.',
        ),
        WordDef(
          'CHEER',
          'Happiness and joy shared among loved ones',
          'Holiday cheer filled the room.',
        ),
        WordDef(
          'FEAST',
          'A lavish festive meal',
          'Gathering for the holiday feast.',
        ),
        WordDef(
          'LIGHT',
          'Twinkling decorative bulbs on roofs and trees',
          'Fairy lights illuminating streets.',
        ),
        WordDef(
          'WISH',
          'A heartfelt hope for good fortune',
          'Making a secret holiday wish.',
        ),
        WordDef(
          'SONG',
          'Musical tune sung during festivals',
          'Festive songs sung by carollers.',
        ),
        WordDef(
          'GLOW',
          'Warm soft light radiating outward',
          'Golden candle glow on the table.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'RESORT',
          'Vacation destination with luxury amenities',
          'Alpine mountain ski resort.',
        ),
        WordDef(
          'RIBBON',
          'Fabric strip used for tying decorative bows',
          'Red satin ribbon on the box.',
        ),
        WordDef(
          'WREATH',
          'Circular arrangement of evergreen branches',
          'Pine wreath on the front door.',
        ),
        WordDef(
          'CANDLE',
          'Wax cylinder with a wick that gives light',
          'Cinnamon scented holiday candle.',
        ),
        WordDef(
          'SLEIGH',
          'Vehicle on runners pulled across snow',
          'Horse-drawn sleigh through snow.',
        ),
        WordDef(
          'TRAVEL',
          'Going to different places for leisure',
          'Holiday travel to visit family.',
        ),
        WordDef(
          'SUNSHINE',
          'Warm bright sunlight on vacation days',
          'Bright sunshine on the beach.',
        ),
        WordDef(
          'LUGGAGE',
          'Bags and suitcases for journey clothes',
          'Packed luggage ready for flight.',
        ),
        WordDef(
          'PARADE',
          'Procession of floats and marching bands',
          'Annual city festival parade.',
        ),
        WordDef(
          'GARLAND',
          'Decorative rope of pine, flowers, or lights',
          'Garland draped along stairs.',
        ),
        WordDef(
          'BAUBLE',
          'Shiny glass ball hung on Christmas trees',
          'Sparkling golden tree bauble.',
        ),
        WordDef(
          'REINDEER',
          'Arctic deer with large antlers',
          'Reindeer grazing in Lapland.',
        ),
        WordDef(
          'HOLIDAY',
          'Day of festivity and freedom from work',
          'Wishing you a happy holiday.',
        ),
        WordDef(
          'CABIN',
          'Small wooden house in a forest or mountain',
          'Log cabin in the snowy woods.',
        ),
        WordDef(
          'WINTER',
          'The coldest season of the year',
          'Frosted winter morning walk.',
        ),
        WordDef(
          'CRUISE',
          'Vacation voyage on a large ship',
          'Caribbean island cruise ship.',
        ),
        WordDef(
          'ISLAND',
          'Land surrounded on all sides by water',
          'Tropical island getaway.',
        ),
        WordDef(
          'CAROLS',
          'Traditional songs sung at Christmas',
          'Singing carols door to door.',
        ),
        WordDef(
          'EGGNOG',
          'Rich drink of milk, eggs, sugar, and nutmeg',
          'Spiced creamy holiday eggnog.',
        ),
        WordDef(
          'COOKIES',
          'Sweet baked treats decorated with icing',
          'Gingerbread holiday cookies.',
        ),
      ],
      longWords: const [
        WordDef(
          'FIREWORKS',
          'Explosive visual displays of colored light',
          'New Year fireworks over the bay.',
        ),
        WordDef(
          'SNOWFLAKE',
          'Delicate crystal of falling snow',
          'Unique symmetrical snowflake.',
        ),
        WordDef(
          'VACATION',
          'Period of leisure time away from work',
          'Summer family beach vacation.',
        ),
        WordDef(
          'ORNAMENT',
          'Decorative item used to embellish trees',
          'Handcrafted ceramic ornament.',
        ),
        WordDef(
          'TRADITION',
          'Customs passed down through generations',
          'Beloved family holiday tradition.',
        ),
        WordDef(
          'CELEBRATE',
          'Honor a festive occasion with joy',
          'Gathering friends to celebrate.',
        ),
        WordDef(
          'FIREPLACE',
          'Brick or stone hearth for warming a room',
          'Warm fire in the fireplace.',
        ),
        WordDef(
          'FESTIVITY',
          'Celebratory joyful activities and mood',
          'Town full of holiday festivity.',
        ),
        WordDef(
          'PASSPORT',
          'Travel document for crossing borders',
          'Valid passport for world travel.',
        ),
        WordDef(
          'GREETINGS',
          'Warm messages of goodwill and cheer',
          'Warm winter season greetings.',
        ),
        WordDef(
          'MISTLETOE',
          'Plant with white berries hung for kissing',
          'Mistletoe above the door frame.',
        ),
        WordDef(
          'NUTCRACKER',
          'Decorative wooden soldier tool for nuts',
          'Watching the Nutcracker ballet.',
        ),
        WordDef(
          'SNOWBOARD',
          'Board ridden down snowy mountain slopes',
          'Carving turns on a snowboard.',
        ),
        WordDef(
          'DECORATION',
          'Embellishments added to beautify spaces',
          'Festive tree and room decoration.',
        ),
        WordDef(
          'SANTA CLAUS',
          'Legendary figure bringing gifts to kids',
          'Leaving cookies for Santa Claus.',
        ),
        WordDef(
          'HOT CHOCOLATE',
          'Warm cocoa drink with marshmallows',
          'Steaming mug of hot chocolate.',
        ),
        WordDef(
          'CANDY CANE',
          'Striped peppermint cane shaped candy',
          'Peppermint candy cane sweet.',
        ),
        WordDef(
          'WINTERTIME',
          'The cold festive season of winter',
          'Magical wintertime snowfall.',
        ),
        WordDef(
          'FIRECRACKER',
          'Small explosive toy producing loud bang',
          'Loud festive firecrackers.',
        ),
        WordDef(
          'GIFT WRAPPING',
          'Decorating presents with paper and ribbon',
          'Colorful gift wrapping paper.',
        ),
      ],
    ),

    // 3. Jobs
    ChapterDef(
      id: 3,
      key: 'jobs',
      title: 'Jobs',
      iconAsset: 'assets/chapter_images/jobs.png',
      themeColor: 0xFF3F51B5,
      shortWords: const [
        WordDef(
          'CHEF',
          'A professional cook in a restaurant',
          'Executive chef preparing dinner.',
        ),
        WordDef(
          'PILOT',
          'A person who operates aircraft controls',
          'Commercial airline flight pilot.',
        ),
        WordDef(
          'NURSE',
          'Trained healthcare worker caring for sick',
          'Dedicated hospital emergency nurse.',
        ),
        WordDef(
          'ACTOR',
          'A person portraying characters on stage',
          'Lead actor in the Broadway play.',
        ),
        WordDef(
          'JUDGE',
          'A public officer deciding court cases',
          'Supreme court presiding judge.',
        ),
        WordDef(
          'CLERK',
          'Person doing administrative office work',
          'Helpful municipal city clerk.',
        ),
        WordDef(
          'GUARD',
          'Person keeping watch and protecting safety',
          'Security guard patrolling halls.',
        ),
        WordDef(
          'COACH',
          'Instructor training athletes in sports',
          'Head coach designing game plays.',
        ),
        WordDef(
          'GUIDE',
          'Person showing tourists around sights',
          'Knowledgeable museum tour guide.',
        ),
        WordDef(
          'BAKER',
          'Professional who bakes bread and pastries',
          'Artisan sourdough morning baker.',
        ),
        WordDef(
          'MASON',
          'Tradesperson who builds with stone or brick',
          'Skilled stone mason crafting walls.',
        ),
        WordDef(
          'MINER',
          'Worker extracting ores and minerals',
          'Hardworking underground coal miner.',
        ),
        WordDef(
          'SAILOR',
          'Person working aboard a ship or vessel',
          'Experienced naval ocean sailor.',
        ),
        WordDef(
          'AGENT',
          'Person acting on behalf of clients',
          'Licensed residential real estate agent.',
        ),
        WordDef(
          'DRIVER',
          'Person operating transport vehicles',
          'Professional city transit bus driver.',
        ),
        WordDef(
          'TAILOR',
          'Person making and fitting custom clothing',
          'Custom bespoke suit tailor.',
        ),
        WordDef(
          'WRITER',
          'Author creating books and stories',
          'Award-winning fiction novelist writer.',
        ),
        WordDef(
          'PAINTER',
          'Artist creating artwork with pigments',
          'Landscape oil canvas painter.',
        ),
        WordDef(
          'DOCTOR',
          'Licensed medical physician treating patients',
          'Family medicine clinic doctor.',
        ),
        WordDef(
          'FARMER',
          'Person growing crops and raising livestock',
          'Organic vegetable harvest farmer.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'LAWYER',
          'Legal professional representing clients in court',
          'Defense lawyer presenting evidence.',
        ),
        WordDef(
          'DENTIST',
          'Healthcare doctor specializing in teeth care',
          'Checking teeth at dental clinic.',
        ),
        WordDef(
          'SURGEON',
          'Medical doctor performing surgical operations',
          'Cardiac surgeon in operating room.',
        ),
        WordDef(
          'OFFICER',
          'Person holding a position of authority',
          'Police officer keeping streets safe.',
        ),
        WordDef(
          'TEACHER',
          'Educator instructing students in schools',
          'Passionate science high school teacher.',
        ),
        WordDef(
          'PLUMBER',
          'Tradesperson fitting water pipes and drains',
          'Plumber fixing leaking kitchen pipe.',
        ),
        WordDef(
          'ARTIST',
          'Person creating visual or musical fine arts',
          'Talented digital concept artist.',
        ),
        WordDef(
          'SINGER',
          'Musician performing vocal musical pieces',
          'Opera soprano lead solo singer.',
        ),
        WordDef(
          'SOLDIER',
          'Member of an army serving national defense',
          'Brave soldier stationed at base.',
        ),
        WordDef(
          'BUILDER',
          'Construction professional erecting buildings',
          'Master builder raising roof beams.',
        ),
        WordDef(
          'BANKER',
          'Officer managing bank investments and loans',
          'Financial investment commercial banker.',
        ),
        WordDef(
          'BARBER',
          'Person cutting and styling mens hair and beards',
          'Classic vintage barbershop barber.',
        ),
        WordDef(
          'AUTHOR',
          'Creator of published literary works',
          'Bestselling fantasy book author.',
        ),
        WordDef(
          'FLORIST',
          'Person arranging and selling fresh flowers',
          'Florist creating bridal bouquets.',
        ),
        WordDef(
          'OPTICIAN',
          'Specialist making and fitting eyeglasses',
          'Optician checking lens prescription.',
        ),
        WordDef(
          'EDITOR',
          'Professional revising manuscripts and articles',
          'Senior newspaper news editor.',
        ),
        WordDef(
          'BUTCHER',
          'Tradesperson preparing and selling meat',
          'Butcher carving prime beef cuts.',
        ),
        WordDef(
          'SAILOR',
          'Person navigating oceanic voyages',
          'Experienced coastal cargo sailor.',
        ),
        WordDef(
          'PILOT',
          'Aviator navigating transport aircraft',
          'Helicopter rescue mission pilot.',
        ),
        WordDef(
          'BARISTA',
          'Person preparing espresso coffee drinks',
          'Barista pouring latte art foam.',
        ),
      ],
      longWords: const [
        WordDef(
          'ENGINEER',
          'Professional designing machinery and systems',
          'Software engineer coding mobile apps.',
        ),
        WordDef(
          'SCIENTIST',
          'Expert conducting systematic research studies',
          'Research scientist in laboratory.',
        ),
        WordDef(
          'FIREFIGHTER',
          'Rescuer extinguishing fires and saving lives',
          'Brave firefighter rescuing citizens.',
        ),
        WordDef(
          'ASTRONAUT',
          'Space explorer travelling into cosmos orbit',
          'Astronaut floating on space station.',
        ),
        WordDef(
          'JOURNALIST',
          'Reporter investigating and writing news stories',
          'Investigative investigative journalist.',
        ),
        WordDef(
          'ARCHITECT',
          'Professional designing architectural buildings',
          'Architect drawing building blueprints.',
        ),
        WordDef(
          'PHARMACIST',
          'Healthcare expert dispensing medications',
          'Pharmacist explaining prescription doses.',
        ),
        WordDef(
          'DETECTIVE',
          'Investigator solving criminal mysteries',
          'Police detective gathering crime clues.',
        ),
        WordDef(
          'PROGRAMMER',
          'Developer writing code and software programs',
          'Full-stack computer programmer.',
        ),
        WordDef(
          'ACCOUNTANT',
          'Financial professional auditing accounts',
          'Certified chartered accountant.',
        ),
        WordDef(
          'ELECTRICIAN',
          'Tradesperson installing electrical circuits',
          'Electrician wiring household breaker.',
        ),
        WordDef(
          'VETERINARIAN',
          'Medical doctor treating animals and pets',
          'Veterinarian examining sick puppy.',
        ),
        WordDef(
          'PHOTOGRAPHER',
          'Visual artist capturing images on cameras',
          'Wildlife photographer in savanna.',
        ),
        WordDef(
          'PSYCHOLOGIST',
          'Specialist studying mental processes and behavior',
          'Clinical psychologist counselling.',
        ),
        WordDef(
          'STATISTICIAN',
          'Mathematician analyzing data and statistics',
          'Data scientist and statistician.',
        ),
        WordDef(
          'METEOROLOGIST',
          'Weather scientist forecasting forecasts',
          'TV meteorologist predicting storms.',
        ),
        WordDef(
          'PALEONTOLOGIST',
          'Scientist studying ancient dinosaur fossils',
          'Paleontologist excavating bones.',
        ),
        WordDef(
          'OCEANOGRAPHER',
          'Marine scientist studying oceans and depths',
          'Deep sea oceanographer studying currents.',
        ),
        WordDef(
          'TRANSLATOR',
          'Professional converting texts across languages',
          'Simultaneous diplomatic translator.',
        ),
        WordDef(
          'NUTRITIONIST',
          'Dietary advisor promoting healthy eating',
          'Certified clinical sports nutritionist.',
        ),
      ],
    ),

    // 4. Electronics
    ChapterDef(
      id: 4,
      key: 'electronics',
      title: 'Electronics',
      iconAsset: 'assets/chapter_images/electronics.png',
      themeColor: 0xFF2196F3,
      shortWords: const [
        WordDef(
          'CHIP',
          'Silicon microchip with electronic circuits',
          'Fast processing computer chip.',
        ),
        WordDef(
          'WIRE',
          'Metal strand conducting electrical currents',
          'Copper wire connected to terminal.',
        ),
        WordDef(
          'PLUG',
          'Connector inserting into wall sockets',
          'Three-pin power adapter plug.',
        ),
        WordDef(
          'PORT',
          'Interface slot connecting cables to devices',
          'High-speed USB data transfer port.',
        ),
        WordDef(
          'CORD',
          'Insulated flexible electrical cable',
          'Durable braided charging cord.',
        ),
        WordDef(
          'DATA',
          'Digital information processed by computers',
          'Encrypted cloud storage data.',
        ),
        WordDef(
          'BYTE',
          'Unit of digital memory consisting of 8 bits',
          'Kilobytes and megabytes of memory.',
        ),
        WordDef(
          'CODE',
          'Instructions written for computer programs',
          'Clean readable source code logic.',
        ),
        WordDef(
          'DISC',
          'Circular optical data storage medium',
          'Compact disc with audio tracks.',
        ),
        WordDef(
          'GRID',
          'Network of interconnected electrical lines',
          'Power grid supplying city energy.',
        ),
        WordDef(
          'CELL',
          'Single unit generating electric voltage',
          'Rechargeable lithium battery cell.',
        ),
        WordDef(
          'NODE',
          'Point of connection in a computing network',
          'Server node transmitting packets.',
        ),
        WordDef(
          'DRIVE',
          'Device storing files and software data',
          'Fast solid-state hard drive.',
        ),
        WordDef(
          'RAM',
          'Random access temporary working memory',
          'High-speed DDR5 system memory RAM.',
        ),
        WordDef(
          'CPU',
          'Central processing unit brain of a computer',
          'Multicore processing desktop CPU.',
        ),
        WordDef(
          'GPU',
          'Graphics processing unit rendering 3D visuals',
          'Dedicated ray-tracing graphics GPU.',
        ),
        WordDef(
          'WIFI',
          'Wireless radio networking technology',
          'Fast dual-band home wifi router.',
        ),
        WordDef(
          'FAN',
          'Cooling device dissipating circuit heat',
          'Silent computer cooling fan.',
        ),
        WordDef(
          'LED',
          'Light emitting diode semiconductor bulb',
          'Energy efficient RGB status LED.',
        ),
        WordDef(
          'JACK',
          'Socket connector for audio headphones',
          'Universal 3.5mm stereo audio jack.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'CAMERA',
          'Optical device capturing photos and video',
          'Digital mirrorless 4K camera.',
        ),
        WordDef(
          'LAPTOP',
          'Portable personal computer with screen',
          'Sleek lightweight work laptop.',
        ),
        WordDef(
          'SCREEN',
          'Display panel rendering visual pixels',
          'Ultra HD OLED display screen.',
        ),
        WordDef(
          'SENSOR',
          'Device detecting physical input signals',
          'Optical fingerprint scanner sensor.',
        ),
        WordDef(
          'ROUTER',
          'Networking device directing internet traffic',
          'Gigabit wireless mesh router.',
        ),
        WordDef(
          'SERVER',
          'Computer hosting networked applications',
          'Cloud data center hosting server.',
        ),
        WordDef(
          'SOCKET',
          'Receptacle receiving power plugs or chips',
          'Wall outlet electric power socket.',
        ),
        WordDef(
          'SWITCH',
          'Component breaking or connecting circuits',
          'Toggle power on-off wall switch.',
        ),
        WordDef(
          'DRONE',
          'Unmanned aerial vehicle piloted remotely',
          'Quadcopter camera flying drone.',
        ),
        WordDef(
          'TABLET',
          'Portable touchscreen computing device',
          'Digital drawing stylus pen tablet.',
        ),
        WordDef(
          'MEMORY',
          'Component retaining digital data storage',
          'Internal flash storage memory.',
        ),
        WordDef(
          'CIRCUIT',
          'Complete path for electric current flow',
          'Printed circuit board with traces.',
        ),
        WordDef(
          'MODEM',
          'Device modulating internet broadband signals',
          'Fiber optic high speed modem.',
        ),
        WordDef(
          'SPEAKER',
          'Device converting audio signals into sound',
          'Bluetooth wireless stereo speaker.',
        ),
        WordDef(
          'BATTERY',
          'Chemical cell supplying electric power',
          'Long-lasting lithium-ion battery.',
        ),
        WordDef(
          'REMOTE',
          'Handheld controller transmitting signals',
          'Infrared television remote control.',
        ),
        WordDef(
          'CHARGER',
          'Device replenishing battery electrical energy',
          'Fast USB power delivery charger.',
        ),
        WordDef(
          'ANTENNA',
          'Conductor radiating or receiving radio waves',
          'Telescopic wireless radio antenna.',
        ),
        WordDef(
          'SCANNER',
          'Optical device capturing document images',
          'Flatbed color document scanner.',
        ),
        WordDef(
          'PRINTER',
          'Machine producing text and images on paper',
          'Wireless laser color printer.',
        ),
      ],
      longWords: const [
        WordDef(
          'SMARTPHONE',
          'Handheld mobile device with touch screen',
          'Flagship 5G dual-camera smartphone.',
        ),
        WordDef(
          'PROCESSOR',
          'Integrated circuit executing computer logic',
          'Octa-core high-speed CPU processor.',
        ),
        WordDef(
          'HEADPHONES',
          'Audio speakers worn comfortably over ears',
          'Noise-cancelling wireless headphones.',
        ),
        WordDef(
          'MICROPHONE',
          'Transducer converting sound waves to signal',
          'Studio condenser podcast microphone.',
        ),
        WordDef(
          'TRANSISTOR',
          'Semiconductor amplifying or switching signals',
          'Nanometer silicon gate transistor.',
        ),
        WordDef(
          'CAPACITOR',
          'Component storing electrostatic energy charge',
          'Ceramic filtering circuit capacitor.',
        ),
        WordDef(
          'MOTHERBOARD',
          'Main printed circuit board holding CPU and RAM',
          'Gaming motherboard with heat sinks.',
        ),
        WordDef(
          'TELEVISION',
          'Electronic device receiving broadcast video',
          'Smart 65-inch 4K HDR television.',
        ),
        WordDef(
          'BLUETOOTH',
          'Short-range wireless device pairing standard',
          'Pairing Bluetooth earbuds to phone.',
        ),
        WordDef(
          'SEMICONDUCTOR',
          'Material with variable electrical conductivity',
          'Silicon wafer semiconductor chip.',
        ),
        WordDef(
          'CONTROLLER',
          'Handheld input device for playing video games',
          'Wireless vibrating gaming controller.',
        ),
        WordDef(
          'OSCILLOSCOPE',
          'Electronic tool graphing signal wave voltages',
          'Testing circuits on an oscilloscope.',
        ),
        WordDef(
          'TOUCHSCREEN',
          'Display detecting fingertip touch gestures',
          'Responsive glass capacitive touchscreen.',
        ),
        WordDef(
          'MICROCHIP',
          'Miniaturized electronic circuit on silicon',
          'Advanced microchip manufacturing fab.',
        ),
        WordDef(
          'TRANSMITTER',
          'Device sending out electromagnetic signals',
          'Radio frequency signal transmitter.',
        ),
        WordDef(
          'AMPLIFIER',
          'Electronic circuit boosting audio or signal level',
          'Stereo sound tube amplifier.',
        ),
        WordDef(
          'RESISTOR',
          'Component resisting flow of electrical current',
          'Color-banded carbon film resistor.',
        ),
        WordDef(
          'SMARTWATCH',
          'Wearable digital wrist watch with sensors',
          'Fitness tracking AMOLED smartwatch.',
        ),
        WordDef(
          'PROJECTOR',
          'Device projecting video images on big screens',
          'Home theater digital laser projector.',
        ),
        WordDef(
          'SUBWOOFER',
          'Loudspeaker dedicated to deep bass sound',
          'Punchy low frequency audio subwoofer.',
        ),
      ],
    ),

    // 5. Books
    ChapterDef(
      id: 5,
      key: 'books',
      title: 'Books',
      iconAsset: 'assets/chapter_images/books.png',
      themeColor: 0xFF795548,
      shortWords: const [
        WordDef(
          'BOOK',
          'Written or printed work bound with covers',
          'Opening a new hardcover novel book.',
        ),
        WordDef(
          'PAGE',
          'One side of a leaf of a book or notebook',
          'Turning the page of an exciting tale.',
        ),
        WordDef(
          'POEM',
          'Piece of writing in verse expressing emotion',
          'Lyrical rhyming classical romantic poem.',
        ),
        WordDef(
          'PLOT',
          'The main sequence of events in a story',
          'Engaging story plot with surprises.',
        ),
        WordDef(
          'HERO',
          'Main character admired for courage and deeds',
          'Brave hero saving the kingdom.',
        ),
        WordDef(
          'TALE',
          'A narrative story of real or imaginary events',
          'Enchanting bedtime fairy tale.',
        ),
        WordDef(
          'TEXT',
          'The written words of a book or document',
          'Reading ancient philosophical text.',
        ),
        WordDef(
          'EPIC',
          'Long narrative poem or story of heroism',
          'Grand mythological historical epic.',
        ),
        WordDef(
          'RHYME',
          'Correspondence of sound between words',
          'Nursery rhyme with catchy verses.',
        ),
        WordDef(
          'PROSE',
          'Written language in ordinary grammatical form',
          'Poetic descriptive narrative prose.',
        ),
        WordDef(
          'MYTH',
          'Traditional story explaining nature or beliefs',
          'Greek myth of Icarus and the sun.',
        ),
        WordDef(
          'LORE',
          'Body of traditions and knowledge on a subject',
          'Deep fantasy worldbuilding lore.',
        ),
        WordDef(
          'WORD',
          'Single distinct meaningful element of speech',
          'Carefully chosen evocative word.',
        ),
        WordDef(
          'FOLK',
          'Traditional customs and stories of people',
          'Old cultural folk tales passed down.',
        ),
        WordDef(
          'READ',
          'Look at and comprehend written text',
          'Curling up on the couch to read.',
        ),
        WordDef(
          'TOME',
          'A large, heavy, scholarly book',
          'Ancient dusty leather-bound tome.',
        ),
        WordDef(
          'FABLE',
          'Short story with animal characters conveying morals',
          'Aesop classic tortoise and hare fable.',
        ),
        WordDef(
          'CLUE',
          'Piece of evidence leading to solving mysteries',
          'Detective finding a subtle story clue.',
        ),
        WordDef(
          'QUILL',
          'Feather pen used for writing with ink',
          'Writing letters with a dipping quill.',
        ),
        WordDef(
          'INK',
          'Colored liquid used for writing and printing',
          'Permanent black fountain pen ink.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'NOVEL',
          'Fictitious prose narrative of book length',
          'Engrossing mystery thriller novel.',
        ),
        WordDef(
          'AUTHOR',
          'Writer of a book, article, or document',
          'Autograph from the favorite author.',
        ),
        WordDef(
          'POETRY',
          'Literary work in which expression of feelings is given',
          'Reading classical romantic poetry.',
        ),
        WordDef(
          'CHAPTER',
          'Main division of a book marked by number',
          'Starting chapter five of the novel.',
        ),
        WordDef(
          'LIBRARY',
          'Building containing collections of books to borrow',
          'Quiet community public library.',
        ),
        WordDef(
          'WRITER',
          'Person who writes books or articles professionally',
          'Talented historical fiction writer.',
        ),
        WordDef(
          'STORY',
          'Account of imaginary or real people and events',
          'Spellbinding bedtime adventure story.',
        ),
        WordDef(
          'MANUAL',
          'Book of instructions or guidance',
          'User manual explaining appliance setup.',
        ),
        WordDef(
          'JOURNAL',
          'Newspaper or magazine dealing with a subject',
          'Daily personal reflective journal.',
        ),
        WordDef(
          'MEMOIR',
          'Historical account written from personal knowledge',
          'Moving autobiographical life memoir.',
        ),
        WordDef(
          'BALLAD',
          'Poem or song narrating a story in short stanzas',
          'Folk ballad of medieval knights.',
        ),
        WordDef(
          'COMICS',
          'Publication consisting of comic art sequences',
          'Superhero graphic novel comics.',
        ),
        WordDef(
          'SERIES',
          'Sequence of books continuing a shared storyline',
          'Seven-volume fantasy book series.',
        ),
        WordDef(
          'ESSAY',
          'Short piece of writing on a particular subject',
          'Critical analytical literary essay.',
        ),
        WordDef(
          'SCRIBE',
          'Person who copies out documents by hand',
          'Ancient royal scribe copying scrolls.',
        ),
        WordDef(
          'RHYMES',
          'Words that match in ending vowel sounds',
          'Playful children poetry rhymes.',
        ),
        WordDef(
          'SCENE',
          'Division of an act presenting continuous action',
          'Dramatic climactic story scene.',
        ),
        WordDef(
          'THEME',
          'Underlying idea or subject in an artistic work',
          'Central theme of courage and hope.',
        ),
        WordDef(
          'STANZA',
          'Group of lines forming a recurring unit in poem',
          'Four-line rhyming poem stanza.',
        ),
        WordDef(
          'SCRIPT',
          'Handwriting or written text of a play or film',
          'Screenwriter reading the film script.',
        ),
      ],
      longWords: const [
        WordDef(
          'CHARACTER',
          'A person portrayed in a novel, play, or movie',
          'Complex multi-layered story character.',
        ),
        WordDef(
          'LITERATURE',
          'Written works considered of artistic value',
          'Studying classic world literature.',
        ),
        WordDef(
          'BIOGRAPHY',
          'Account of someone life written by another',
          'Detailed historical presidential biography.',
        ),
        WordDef(
          'PUBLISHER',
          'Company producing and distributing books',
          'International book publishing house.',
        ),
        WordDef(
          'BOOKSTORE',
          'Shop where books are sold to readers',
          'Cozy independent downtown bookstore.',
        ),
        WordDef(
          'BESTSELLER',
          'A book that sells in very large numbers',
          'Topping the national bestseller list.',
        ),
        WordDef(
          'ENCYCLOPEDIA',
          'Comprehensive reference work covering knowledge',
          'Multi-volume reference encyclopedia.',
        ),
        WordDef(
          'MANUSCRIPT',
          'Book or document written before printing',
          'Preserved medieval illuminated manuscript.',
        ),
        WordDef(
          'DICTIONARY',
          'Book listing words with meanings and phonetics',
          'Comprehensive unabridged dictionary.',
        ),
        WordDef(
          'NARRATIVE',
          'Spoken or written account of connected events',
          'Compelling first-person story narrative.',
        ),
        WordDef(
          'ANTHOLOGY',
          'Published collection of poems or stories',
          'Anthology of classic science fiction.',
        ),
        WordDef(
          'PLAYWRIGHT',
          'Person who writes theatrical stage plays',
          'Celebrated Elizabethan drama playwright.',
        ),
        WordDef(
          'PAPERBACK',
          'Book with a flexible paper binding cover',
          'Lightweight portable travel paperback.',
        ),
        WordDef(
          'BOOKSHELF',
          'Shelf on which books are organized and kept',
          'Tall wooden bookshelf full of novels.',
        ),
        WordDef(
          'HEADLINE',
          'Heading at the top of an article or page',
          'Bold front-page newspaper headline.',
        ),
        WordDef(
          'VOCABULARY',
          'The body of words known and used by a person',
          'Expanding vocabulary through daily reading.',
        ),
        WordDef(
          'CALLIGRAPHY',
          'Decorative handwriting or handwritten lettering',
          'Elegant ink calligraphy invitations.',
        ),
        WordDef(
          'PROTAGONIST',
          'The leading character in a drama or novel',
          'Courageous protagonist solving crimes.',
        ),
        WordDef(
          'BIBLIOGRAPHY',
          'List of the books of a specific author or topic',
          'Academic research bibliography page.',
        ),
        WordDef(
          'SCREENPLAY',
          'Script of a film including acting instructions',
          'Award-winning cinematic screenplay.',
        ),
      ],
    ),

    // 6. Games
    ChapterDef(
      id: 6,
      key: 'games',
      title: 'Games',
      iconAsset: 'assets/chapter_images/games.png',
      themeColor: 0xFF9C27B0,
      shortWords: const [
        WordDef(
          'GAME',
          'An activity that one engages in for amusement',
          'Fun multiplayer family board game.',
        ),
        WordDef(
          'DICE',
          'Small cubes marked with spots used in games',
          'Rolling a pair of lucky six-sided dice.',
        ),
        WordDef(
          'CARD',
          'Rectangular pasteboard used in playing games',
          'Shuffling the standard deck of cards.',
        ),
        WordDef(
          'PLAY',
          'Engage in activity for enjoyment and recreation',
          'Gathering with friends to play games.',
        ),
        WordDef(
          'TEAM',
          'Group of players forming one side in a game',
          'Coordinated esports championship team.',
        ),
        WordDef(
          'GOAL',
          'Target or objective aimed at in a game',
          'Scoring a winning goal at the buzzer.',
        ),
        WordDef(
          'WIN',
          'Be successful or victorious in a contest',
          'Celebrating a well-earned game win.',
        ),
        WordDef(
          'LOSE',
          'Be deprived of victory in a contest',
          'Learning from errors when you lose.',
        ),
        WordDef(
          'PLED',
          'Tokens moved across a playing board',
          'Moving colored wooden game pawns.',
        ),
        WordDef(
          'TURN',
          'An opportunity to act in a game in succession',
          'Waiting patiently for your turn.',
        ),
        WordDef(
          'RANK',
          'Position in a hierarchy or leaderboard',
          'Climbing to top rank on leaderboard.',
        ),
        WordDef(
          'DECK',
          'A complete pack of playing cards',
          'Drawing a fresh card from the deck.',
        ),
        WordDef(
          'MOVE',
          'Act of changing position of a piece on board',
          'Calculating the next strategic move.',
        ),
        WordDef(
          'ZONE',
          'Specific area or territory on a game map',
          'Navigating the danger zone on map.',
        ),
        WordDef(
          'HERO',
          'Playable character with special powers',
          'Selecting an agile ranged class hero.',
        ),
        WordDef(
          'BOSS',
          'Powerful opponent faced at the end of levels',
          'Defeating the giant dungeon raid boss.',
        ),
        WordDef(
          'LOOT',
          'Treasures and rewards gathered in a game',
          'Opening gold chests full of rare loot.',
        ),
        WordDef(
          'XP',
          'Experience points earned by completing quests',
          'Gaining bonus XP points to level up.',
        ),
        WordDef(
          'MANA',
          'Magical energy used to cast abilities',
          'Recharging mana pool with potions.',
        ),
        WordDef(
          'HP',
          'Hit points representing player health',
          'Restoring lost health HP with bandages.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'PUZZLE',
          'Game testing ingenuity or knowledge',
          'Solving a challenging logic Word Search.',
        ),
        WordDef(
          'PLAYER',
          'Person taking part in a game or sport',
          'Active online multiplayer gamer player.',
        ),
        WordDef(
          'CHESS',
          'Board game of strategic skill for two players',
          'Playing chess on a checkered wooden board.',
        ),
        WordDef(
          'ARCADE',
          'Venue featuring coin-operated game machines',
          'Classic retro 80s video game arcade.',
        ),
        WordDef(
          'AVATAR',
          'Icon or figure representing a person in a game',
          'Customizing the player avatar outfit.',
        ),
        WordDef(
          'QUEST',
          'Long or arduous search or mission in games',
          'Embarking on an epic fantasy quest.',
        ),
        WordDef(
          'CASINO',
          'Facility for certain types of gambling games',
          'Spinning roulette wheels at casino.',
        ),
        WordDef(
          'SHUFFLE',
          'Mix playing cards together in random order',
          'Shuffling the deck before dealing.',
        ),
        WordDef(
          'TACTIC',
          'Action or strategy planned to achieve an aim',
          'Executing a clever ambush game tactic.',
        ),
        WordDef(
          'STRATEGY',
          'Plan of action designed to achieve overall aim',
          'Deep turn-based empire strategy.',
        ),
        WordDef(
          'GAMING',
          'The action or practice of playing video games',
          'Building a high-performance gaming PC.',
        ),
        WordDef(
          'SCORE',
          'Number of points gained in a game',
          'Setting a new world record high score.',
        ),
        WordDef(
          'LEVEL',
          'Stage of difficulty in a video game',
          'Completing level ten with three stars.',
        ),
        WordDef(
          'VICTORY',
          'Success in a game or contest against an opponent',
          'Claiming glorious royal match victory.',
        ),
        WordDef(
          'TROPHY',
          'Cup or decorative object awarded as prize',
          'Earning the platinum gaming trophy.',
        ),
        WordDef(
          'COMBAT',
          'Fighting between armed forces or characters',
          'Engaging in fast-paced martial combat.',
        ),
        WordDef(
          'ACTION',
          'Fast-moving excitement and dynamism in games',
          'Non-stop thrilling action gameplay.',
        ),
        WordDef(
          'PACKET',
          'Bundle of collectible cards or items',
          'Unboxing a rare foil booster packet.',
        ),
        WordDef(
          'KNIGHT',
          'Chess piece shaped like a horse head',
          'Moving the knight piece in an L-shape.',
        ),
        WordDef(
          'BISHOP',
          'Chess piece that moves diagonally',
          'Controlling the diagonal with bishop.',
        ),
      ],
      longWords: const [
        WordDef(
          'CROSSWORD',
          'Puzzle where words are filled in a grid of squares',
          'Solving Sunday newspaper crossword.',
        ),
        WordDef(
          'CHAMPION',
          'Person who has surpassed all rivals in a contest',
          'Reigning world chess grand champion.',
        ),
        WordDef(
          'TOURNAMENT',
          'Series of contests between multiple competitors',
          'Competing in annual e-sports tournament.',
        ),
        WordDef(
          'DOMINOES',
          'Game played with flat rectangular spotted blocks',
          'Matching double six tiles in dominoes.',
        ),
        WordDef(
          'ROULETTE',
          'Gambling game in which a ball drops on wheel',
          'Betting on red and black in roulette.',
        ),
        WordDef(
          'CHECKERS',
          'Board game for two players with disc pieces',
          'Jumping opponent pieces in checkers.',
        ),
        WordDef(
          'LEADERBOARD',
          'Scoreboard showing names of top ranking players',
          'Top ranking position on leaderboard.',
        ),
        WordDef(
          'MULTIPLAYER',
          'Game designed for several players at once',
          'Cooperative online multiplayer match.',
        ),
        WordDef(
          'CONTROLLER',
          'Handheld device used to operate video games',
          'Responsive ergonomic game controller.',
        ),
        WordDef(
          'SIMULATION',
          'Game imitating the operation of a real process',
          'Flight pilot cockpit simulation.',
        ),
        WordDef(
          'CHALLENGE',
          'Call to take part in a contest or test of skill',
          'Accepting daily puzzle challenge.',
        ),
        WordDef(
          'ROLEPLAYING',
          'Acting out roles of characters in a game',
          'Immersive fantasy roleplaying game.',
        ),
        WordDef(
          'ACHIEVEMENT',
          'A thing done successfully with skill',
          'Unlocking hidden game achievement.',
        ),
        WordDef(
          'PLAYGROUND',
          'Outdoor area provided for children to play',
          'Swings and slides in the playground.',
        ),
        WordDef(
          'BACKGAMMON',
          'Board game with counters moved on dice rolls',
          'Ancient board game of backgammon.',
        ),
        WordDef(
          'SCAVENGER',
          'Game where players search for listed items',
          'City-wide scavenger hunt clue quest.',
        ),
        WordDef(
          'CHECKMATE',
          'Winning position in chess where king cannot escape',
          'Delivering fatal endgame checkmate.',
        ),
        WordDef(
          'SCRABBLE',
          'Board word game scoring points with letter tiles',
          'Triple word score bonus in Scrabble.',
        ),
        WordDef(
          'TACTICAL',
          'Showing skill in planning tactics in games',
          'Tactical squad deployment in combat.',
        ),
        WordDef(
          'EXPEDITION',
          'Journey undertaken by a group with purpose',
          'Dangerous jungle temple expedition.',
        ),
      ],
    ),

    // 7. Plants
    ChapterDef(
      id: 7,
      key: 'plants',
      title: 'Plants',
      iconAsset: 'assets/chapter_images/plants.png',
      themeColor: 0xFF4CAF50,
      shortWords: const [
        WordDef(
          'LEAF',
          'Flattened green structure of a plant',
          'Dewdrops on a green morning leaf.',
        ),
        WordDef(
          'ROOT',
          'Part of a plant attaching it into the ground',
          'Deep tree roots absorbing water.',
        ),
        WordDef(
          'STEM',
          'Main body or stalk of a plant or shrub',
          'Sturdy green sunflower stalk stem.',
        ),
        WordDef(
          'SEED',
          'Unit of reproduction of a flowering plant',
          'Planting sunflower seeds in soil.',
        ),
        WordDef(
          'MOSS',
          'Small green nonvascular flowerless plant',
          'Soft green velvety forest moss.',
        ),
        WordDef(
          'FERN',
          'Flowerless plant with feathery fronds',
          'Lush green tropical forest fern.',
        ),
        WordDef(
          'ROSE',
          'Prickly bush bearing fragrant flowers',
          'Velvety fragrant crimson red rose.',
        ),
        WordDef(
          'TREE',
          'Woody perennial plant with trunk and limbs',
          'Mighty oak tree in the meadow.',
        ),
        WordDef(
          'BARK',
          'Tough protective outer sheath of tree trunk',
          'Rough textured birch tree bark.',
        ),
        WordDef(
          'BUD',
          'Compact knoblike growth on a plant',
          'Spring flower buds ready to bloom.',
        ),
        WordDef(
          'PINE',
          'Evergreen tree with needle leaves and cones',
          'Scent of mountain pine forest.',
        ),
        WordDef(
          'WEED',
          'Wild plant growing where it is not wanted',
          'Pulling garden weeds from beds.',
        ),
        WordDef(
          'PALM',
          'Tropical unbranched tree with feathery fronds',
          'Swaying coconut palm on the beach.',
        ),
        WordDef(
          'LILY',
          'Plant with large trumpet-shaped flowers',
          'Fragrant white peace water lily.',
        ),
        WordDef(
          'IVY',
          'Evergreen climbing plant with glossy leaves',
          'English ivy climbing stone walls.',
        ),
        WordDef(
          'SOIL',
          'Upper layer of earth in which plants grow',
          'Rich nutrient-dense garden soil.',
        ),
        WordDef(
          'HERB',
          'Plant used for flavoring, medicine, or scent',
          'Fresh garden basil and mint herb.',
        ),
        WordDef(
          'VINE',
          'Climbing plant with long trailing stems',
          'Grapevine heavy with purple fruit.',
        ),
        WordDef(
          'REED',
          'Tall slender plant growing in water or marsh',
          'Reeds swaying along riverbanks.',
        ),
        WordDef(
          'ALGA',
          'Simple nonflowering aquatic plant organism',
          'Green freshwater pond algae.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'FLOWER',
          'Seed-bearing part of a plant with petals',
          'Bright colorful spring wild flower.',
        ),
        WordDef(
          'BAMBOO',
          'Giant woody tropical grass with hollow stems',
          'Tall resilient green bamboo forest.',
        ),
        WordDef(
          'CACTUS',
          'Succulent plant with thick fleshy spiny stems',
          'Flowering desert saguaro cactus.',
        ),
        WordDef(
          'ORCHID',
          'Plant with complex and showy flowers',
          'Exotic purple moth orchid blossom.',
        ),
        WordDef(
          'BONSAI',
          'Ornamental tree cultivated in pots and pruned',
          'Miniature Japanese potted bonsai.',
        ),
        WordDef(
          'CLOVER',
          'Herbaceous plant with three-lobed leaves',
          'Lucky green four-leaf clover.',
        ),
        WordDef(
          'PETALS',
          'Each of the segments of the corolla of flower',
          'Soft fragrant flower petals.',
        ),
        WordDef(
          'BRANCH',
          'Part of a tree growing out from the trunk',
          'Birds singing on a tree branch.',
        ),
        WordDef(
          'FOLIAGE',
          'Plant leaves collectively',
          'Brilliant autumn golden foliage.',
        ),
        WordDef(
          'POLLEN',
          'Fine powdery substance discharged from stamen',
          'Bees collecting golden flower pollen.',
        ),
        WordDef(
          'SPROUT',
          'A shoot of a plant starting to grow from seed',
          'Green seedling sprout from earth.',
        ),
        WordDef(
          'TULIP',
          'Bulbous spring-flowering plant with cups',
          'Fields of colorful Dutch tulips.',
        ),
        WordDef(
          'DAISY',
          'Small plant bearing flowers with white rays',
          'Yellow-centered white lawn daisy.',
        ),
        WordDef(
          'VIOLET',
          'Plant of genus Viola with purple flowers',
          'Sweet scented wild purple violet.',
        ),
        WordDef(
          'JASMINE',
          'Shrub with fragrant white or yellow flowers',
          'Fragrant night-blooming jasmine.',
        ),
        WordDef(
          'GARDEN',
          'Piece of ground used for growing plants',
          'Lush botanical botanical garden.',
        ),
        WordDef(
          'SHRUB',
          'Woody plant smaller than a tree with stems',
          'Flowering lavender garden shrub.',
        ),
        WordDef(
          'AZALEA',
          'Flowering shrub of the genus Rhododendron',
          'Vibrant pink blooming azalea bush.',
        ),
        WordDef(
          'NATURE',
          'The physical world including plants and animals',
          'Preserving beauty of wild nature.',
        ),
        WordDef(
          'GROVE',
          'Small wood, orchard, or group of trees',
          'Shady fragrant orange fruit grove.',
        ),
      ],
      longWords: const [
        WordDef(
          'BOTANICAL',
          'Relating to plants or the study of botany',
          'Visiting royal botanical glasshouse.',
        ),
        WordDef(
          'EVERGREEN',
          'Plant that retains green leaves throughout year',
          'Evergreen coniferous pine trees.',
        ),
        WordDef(
          'PHOTOSYNTHESIS',
          'Process by which green plants synthesize food',
          'Sunlight powering photosynthesis.',
        ),
        WordDef(
          'SUNFLOWER',
          'Tall plant with a very large golden flower head',
          'Field of bright yellow sunflowers.',
        ),
        WordDef(
          'DANDELION',
          'Weedy plant with yellow flowers and fluffy seeds',
          'Blowing fluffy white dandelion clock.',
        ),
        WordDef(
          'CHLOROPHYLL',
          'Green pigment in plants absorbing light energy',
          'Leaves rich in green chlorophyll.',
        ),
        WordDef(
          'CARNIVOROUS',
          'Plant that traps and digests insects for food',
          'Venus flytrap carnivorous plant.',
        ),
        WordDef(
          'GREENHOUSE',
          'Glass building in which plants are cultivated',
          'Warm tropical glass greenhouse.',
        ),
        WordDef(
          'HORTICULTURE',
          'The art or practice of garden cultivation',
          'Degree in horticulture sciences.',
        ),
        WordDef(
          'GERMINATION',
          'Development of a plant from a seed or spore',
          'Moisture initiating seed germination.',
        ),
        WordDef(
          'SUCCULENT',
          'Plant with thick fleshy leaves retaining water',
          'Potted desert succulent garden.',
        ),
        WordDef(
          'CHRYSANTHEMUM',
          'Plant with brightly colored pompom flower heads',
          'Golden autumn chrysanthemum flower.',
        ),
        WordDef(
          'RHODODENDRON',
          'Shrub with large clusters of bell flowers',
          'Mountain rhododendron bloom trail.',
        ),
        WordDef(
          'POLLINATION',
          'Transfer of pollen to allow fertilization',
          'Honeybees essential for pollination.',
        ),
        WordDef(
          'VEGETATION',
          'Plants considered collectively in an area',
          'Dense tropical jungle vegetation.',
        ),
        WordDef(
          'RAINFOREST',
          'Dense evergreen forest with high annual rainfall',
          'Biodiverse Amazon rainforest canopy.',
        ),
        WordDef(
          'WILDFLOWER',
          'Flower of an uncultivated variety in nature',
          'Carpet of spring meadow wildflowers.',
        ),
        WordDef(
          'EUCALYPTUS',
          'Fast-growing evergreen tree native to Australia',
          'Aromatic blue-green eucalyptus oil.',
        ),
        WordDef(
          'PERENNIAL',
          'Plant living for several years and blooming',
          'Hardy perennial garden border.',
        ),
        WordDef(
          'CONIFEROUS',
          'Tree bearing cones and evergreen needle leaves',
          'High alpine coniferous mountain forest.',
        ),
      ],
    ),

    // 8. Painting
    ChapterDef(
      id: 8,
      key: 'painting',
      title: 'Painting',
      iconAsset: 'assets/chapter_images/painting.png',
      themeColor: 0xFFFF9800,
      shortWords: const [
        WordDef(
          'ART',
          'Expression or application of human creative skill',
          'Appreciating classic modern art.',
        ),
        WordDef(
          'OIL',
          'Oil-based paint pigment used on canvas',
          'Layering traditional oil painting.',
        ),
        WordDef(
          'HUE',
          'A color or shade of a color',
          'Vibrant warm orange sunset hue.',
        ),
        WordDef(
          'TINT',
          'Shade or variety of a color mixed with white',
          'Soft pastel pink flower tint.',
        ),
        WordDef(
          'DRAW',
          'Produce a picture or diagram by making marks',
          'Sketching in a notebook to draw.',
        ),
        WordDef(
          'LINE',
          'Long narrow mark made on a surface',
          'Contour outline line drawing.',
        ),
        WordDef(
          'TONE',
          'Particular quality of brightness or deepness',
          'Subtle transitions in gray tone.',
        ),
        WordDef(
          'FORM',
          'The visible shape or configuration of thing',
          'Sculpting three-dimensional form.',
        ),
        WordDef(
          'WASH',
          'Thin coat of water-diluted paint',
          'Watercolor wet-on-wet sky wash.',
        ),
        WordDef(
          'INK',
          'Colored fluid used for drawing with nibs',
          'Black drawing ink on rough paper.',
        ),
        WordDef(
          'MURAL',
          'Painting executed directly on a wall',
          'Colorful street building wall mural.',
        ),
        WordDef(
          'CLAY',
          'Stiff sticky fine-grained earth used for art',
          'Molding pottery on wheel with clay.',
        ),
        WordDef(
          'FOIL',
          'Thin sheet of metal used in gilding',
          'Adding gold foil leaf accents.',
        ),
        WordDef(
          'WOOD',
          'Hard fibrous material used as painting panel',
          'Painting icons on wood panels.',
        ),
        WordDef(
          'GLUE',
          'Adhesive substance used in collage making',
          'Pasting collage pieces with glue.',
        ),
        WordDef(
          'WAX',
          'Beeswax used in encaustic painting',
          'Melted wax batik fabric painting.',
        ),
        WordDef(
          'GOLD',
          'Yellow precious metal leaf in illuminations',
          'Gilded 24-karat gold leaf halo.',
        ),
        WordDef(
          'DARK',
          'Characterized by little or deep absence of light',
          'Dramatic contrast of dark shadow.',
        ),
        WordDef(
          'SHADE',
          'Color especially with reference to depth',
          'Cool blue shade under tree canopy.',
        ),
        WordDef(
          'MIX',
          'Combine pigments together on a palette',
          'Mixing primary colors on palette.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'CANVAS',
          'Strong unbleached cloth used as painting surface',
          'Stretching cotton canvas on frame.',
        ),
        WordDef(
          'BRUSH',
          'Implement with bristles used for applying paint',
          'Fine sable detail painting brush.',
        ),
        WordDef(
          'EASEL',
          'Wooden frame supporting an artist canvas',
          'Setting up wooden field tripod easel.',
        ),
        WordDef(
          'MUSEUM',
          'Building where art objects are exhibited',
          'Visiting national art history museum.',
        ),
        WordDef(
          'SKETCH',
          'Rough or unfinished drawing made as study',
          'Quick charcoal portrait sketch.',
        ),
        WordDef(
          'DESIGN',
          'Plan or drawing produced to show look',
          'Creating aesthetic graphic design.',
        ),
        WordDef(
          'SHADOW',
          'Dark area or shape produced by body blocking light',
          'Cast shadow under the stone vase.',
        ),
        WordDef(
          'PALETTE',
          'Thin board on which an artist lays colors',
          'Mixing oil paints on oval palette.',
        ),
        WordDef(
          'PASTEL',
          'Crayon consisting of powdered pigment and binder',
          'Soft chalk pastel portrait drawing.',
        ),
        WordDef(
          'ACRYLIC',
          'Fast-drying synthetic polymer paint',
          'Vibrant bold colors with acrylic.',
        ),
        WordDef(
          'STROKE',
          'Mark made by drawing a paintbrush across surface',
          'Expressive loose impressionist stroke.',
        ),
        WordDef(
          'STUDIO',
          'Workroom of an artist, painter, or sculptor',
          'Sunlight filling the painting studio.',
        ),
        WordDef(
          'MODERN',
          'Art characterized by break from past tradition',
          'Gallery of contemporary modern art.',
        ),
        WordDef(
          'ENAMEL',
          'Glossy opaque protective paint coating',
          'Jewelry with colored vitreous enamel.',
        ),
        WordDef(
          'CRAFT',
          'Activity involving skill in making things by hand',
          'Handmade ceramic pottery craft.',
        ),
        WordDef(
          'PENCIL',
          'Instrument for drawing with graphite core',
          'Shading with a 4B graphite pencil.',
        ),
        WordDef(
          'DETAIL',
          'Individual feature, fact, or item in artwork',
          'Intricate realistic brush detail.',
        ),
        WordDef(
          'STENCIL',
          'Sheet with cut-out design through which paint passes',
          'Spraying street art with stencil.',
        ),
        WordDef(
          'COLLAGE',
          'Art made by sticking various materials on backing',
          'Mixed media magazine photo collage.',
        ),
        WordDef(
          'PATINA',
          'Green or brown film on the surface of bronze',
          'Antique bronze statue green patina.',
        ),
      ],
      longWords: const [
        WordDef(
          'WATERCOLOR',
          'Artists paint made with water-soluble binder',
          'Transparent landscape watercolor wash.',
        ),
        WordDef(
          'MASTERPIECE',
          'A work of outstanding artistry or skill',
          'Mona Lisa celebrated masterpiece.',
        ),
        WordDef(
          'SCULPTURE',
          'Art of making three-dimensional forms',
          'Carving marble classical sculpture.',
        ),
        WordDef(
          'EXHIBITION',
          'Public display of works of art in gallery',
          'Visiting solo modern art exhibition.',
        ),
        WordDef(
          'PORTRAIT',
          'Painting or drawing of a person face',
          'Renaissance oil portrait of noble.',
        ),
        WordDef(
          'LANDSCAPE',
          'Painting depicting natural inland scenery',
          'Sweeping mountain valley landscape.',
        ),
        WordDef(
          'IMPRESSIONISM',
          '19th-century art style emphasizing light',
          'Monet water lilies impressionism.',
        ),
        WordDef(
          'ILLUSTRATION',
          'Picture illustrating a book or story',
          'Whimsical storybook illustration.',
        ),
        WordDef(
          'PIGMENTATION',
          'Natural coloring matter in art paints',
          'Rich deep blue lapis lazuli pigment.',
        ),
        WordDef(
          'PERSPECTIVE',
          'Art of drawing two dimensions with depth',
          'Linear one-point perspective grid.',
        ),
        WordDef(
          'SURREALISM',
          '20th-century art exploring unconscious dream imagery',
          'Salvador Dali melting clock surrealism.',
        ),
        WordDef(
          'ABSTRACT',
          'Art that does not attempt to represent external reality',
          'Vibrant geometric abstract art.',
        ),
        WordDef(
          'RENAISSANCE',
          'Revival of European art from 14th to 17th century',
          'Masterworks of Italian Renaissance.',
        ),
        WordDef(
          'CHIAROSCURO',
          'Treatment of light and shade in drawing and painting',
          'Caravaggio dramatic chiaroscuro.',
        ),
        WordDef(
          'CALLIGRAPHY',
          'Decorative visual art of stylized lettering',
          'Traditional Chinese brush calligraphy.',
        ),
        WordDef(
          'STILL LIFE',
          'Painting of inanimate objects such as fruit and vases',
          'Dutch golden age still life flowers.',
        ),
        WordDef(
          'FRESCO',
          'Painting done rapidly in watercolor on wet plaster',
          'Vatican chapel painted ceiling fresco.',
        ),
        WordDef(
          'EXPRESSION',
          'Conveying feeling and mood in artwork',
          'Raw emotional artistic expression.',
        ),
        WordDef(
          'PRINTMAKING',
          'Process of creating artworks by printing on paper',
          'Linocut and woodblock printmaking.',
        ),
        WordDef(
          'COMPOSITION',
          'Arrangement of visual elements in an artwork',
          'Balanced rule-of-thirds composition.',
        ),
      ],
    ),

    // 9. Words
    ChapterDef(
      id: 9,
      key: 'words',
      title: 'Words',
      iconAsset: 'assets/chapter_images/words.png',
      themeColor: 0xFF673AB7,
      shortWords: const [
        WordDef(
          'WORD',
          'Single distinct element of language',
          'Every word has meaning and origin.',
        ),
        WordDef(
          'TEXT',
          'Written words of a document or book',
          'Reading original historical text.',
        ),
        WordDef(
          'VERB',
          'Word used to describe an action or state',
          'Action verb like run and jump.',
        ),
        WordDef(
          'NOUN',
          'Word identifying person, place, or thing',
          'Proper noun like London or river.',
        ),
        WordDef(
          'ROOT',
          'Basic core of a word from which others grow',
          'Latin root word of vocabulary.',
        ),
        WordDef(
          'TERM',
          'Word or phrase used to describe a concept',
          'Scientific terminology term.',
        ),
        WordDef(
          'SLANG',
          'Informal words and expressions used in speech',
          'Modern youth cultural slang.',
        ),
        WordDef(
          'TALK',
          'Speak in order to give information',
          'Friendly conversation talk.',
        ),
        WordDef(
          'RHYME',
          'Correspondence of ending sounds in words',
          'Words that rhyme like cat and hat.',
        ),
        WordDef(
          'SPELL',
          'Write or name the letters of a word',
          'Learning to spell difficult words.',
        ),
        WordDef(
          'SIGN',
          'Gesture or mark conveying meaning',
          'Sign language communication.',
        ),
        WordDef(
          'FONT',
          'Set of type of one particular design',
          'Clean modern sans-serif font.',
        ),
        WordDef(
          'READ',
          'Look at and comprehend written text',
          'Ability to read and write fluent.',
        ),
        WordDef(
          'EDIT',
          'Prepare written material for publication',
          'Editing manuscript for clarity.',
        ),
        WordDef(
          'NOTE',
          'Brief record of facts or topics written down',
          'Taking lecture study notes.',
        ),
        WordDef(
          'PAGE',
          'One side of a sheet of paper in book',
          'Turning to the next glossary page.',
        ),
        WordDef(
          'LORE',
          'Traditional knowledge and spoken stories',
          'Folkloric tribal ancestral lore.',
        ),
        WordDef(
          'MYTH',
          'Traditional story explaining world beliefs',
          'Greek myth told across eras.',
        ),
        WordDef(
          'EPIC',
          'Long narrative poem describing heroic deeds',
          'Ancient Mesopotamian Gilgamesh epic.',
        ),
        WordDef(
          'TALE',
          'Story of real or imaginary events',
          'Fascinating bedtime fairy tale.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'SYNONYM',
          'Word having same or nearly same meaning as another',
          'Finding a rich descriptive synonym.',
        ),
        WordDef(
          'ANTONYM',
          'Word opposite in meaning to another',
          'Hot and cold are direct antonyms.',
        ),
        WordDef(
          'ACRONYM',
          'Abbreviation formed from initial letters',
          'NASA is an acronym for space agency.',
        ),
        WordDef(
          'IDIOM',
          'Group of words with figurative non-literal meaning',
          'Bite the bullet is a famous idiom.',
        ),
        WordDef(
          'PHRASE',
          'Small group of words standing together',
          'Catchy advertising slogan phrase.',
        ),
        WordDef(
          'GRAMMAR',
          'Whole system and structure of a language',
          'Mastering rules of English grammar.',
        ),
        WordDef(
          'DIALECT',
          'Form of language peculiar to a region',
          'Regional Scottish coastal dialect.',
        ),
        WordDef(
          'SPEECH',
          'Expression of thoughts in spoken words',
          'Giving a motivational keynote speech.',
        ),
        WordDef(
          'POETRY',
          'Literary work using rhythm and imagery',
          'Appreciating sonnets and poetry.',
        ),
        WordDef(
          'SYMBOL',
          'Mark or character used as representation',
          'Mathematical notation symbol.',
        ),
        WordDef(
          'JARGON',
          'Special words used by particular profession',
          'Medical anatomical clinical jargon.',
        ),
        WordDef(
          'PROVERB',
          'Short saying stating general truth or advice',
          'Actions speak louder proverb.',
        ),
        WordDef(
          'PREFIX',
          'Affix placed before the stem of a word',
          'Un and re are common word prefixes.',
        ),
        WordDef(
          'SUFFIX',
          'Affix placed after the stem of a word',
          'Adding ly and ing word suffixes.',
        ),
        WordDef(
          'CLAUSE',
          'Unit of grammatical organization with verb',
          'Dependent conditional sentence clause.',
        ),
        WordDef(
          'ACCENT',
          'Distinctive mode of pronunciation of language',
          'Charming melodic foreign accent.',
        ),
        WordDef(
          'LEXICON',
          'Vocabulary of a person, language, or field',
          'Expanding personal mental lexicon.',
        ),
        WordDef(
          'MAXIM',
          'Short statement expressing general truth or rule',
          'Living by the golden rule maxim.',
        ),
        WordDef(
          'SLOGAN',
          'Short memorable motto used in advertising',
          'Inspiring brand campaign slogan.',
        ),
        WordDef(
          'STORY',
          'Narrative account of real or imagined events',
          'Engrossing mystery detective story.',
        ),
      ],
      longWords: const [
        WordDef(
          'VOCABULARY',
          'The body of words known to an individual',
          'Expanding English language vocabulary.',
        ),
        WordDef(
          'DICTIONARY',
          'Book listing words with definitions and origins',
          'Searching definitions in dictionary.',
        ),
        WordDef(
          'ETYMOLOGY',
          'Study of the origin of words and their changes',
          'Tracing Greek etymology of words.',
        ),
        WordDef(
          'ALLITERATION',
          'Repetition of initial consonant sounds in words',
          'Peter Piper picked pepper alliteration.',
        ),
        WordDef(
          'ONOMATOPOEIA',
          'Formation of a word from a sound associated with it',
          'Buzz and sizzle are onomatopoeia.',
        ),
        WordDef(
          'PUNCTUATION',
          'Marks used in writing to clarify meaning',
          'Proper comma and period punctuation.',
        ),
        WordDef(
          'METAPHOR',
          'Figure of speech applying term to non-literal thing',
          'Time is a thief figurative metaphor.',
        ),
        WordDef(
          'LINGUISTICS',
          'The scientific study of human language',
          'Professor of structural linguistics.',
        ),
        WordDef(
          'HOMOPHONE',
          'Words having same pronunciation but different meaning',
          'Hear and here are homophones.',
        ),
        WordDef(
          'THESAURUS',
          'Book that lists words in groups of synonyms',
          'Looking up colorful synonyms in thesaurus.',
        ),
        WordDef(
          'PRONUNCIATION',
          'The way in which a word is spoken aloud',
          'Clear phonetic vowel pronunciation.',
        ),
        WordDef(
          'TRANSLATION',
          'Expressing the sense of words in another language',
          'Accurate poetic French translation.',
        ),
        WordDef(
          'CALLIGRAPHY',
          'Visual art of decorative handwriting',
          'Elegant wedding invitation calligraphy.',
        ),
        WordDef(
          'CONJUGATION',
          'Variation of the form of a verb in grammar',
          'Learning past tense verb conjugation.',
        ),
        WordDef(
          'ORTHOGRAPHY',
          'Conventional spelling system of a language',
          'Standard English orthography rules.',
        ),
        WordDef(
          'HIEROGLYPHICS',
          'Enigmatic or incomprehensible symbols',
          'Egyptian pyramid carved hieroglyphics.',
        ),
        WordDef(
          'ENCYCLOPEDIA',
          'Book giving information on many subjects',
          'Multi-volume historical encyclopedia.',
        ),
        WordDef(
          'PALINDROME',
          'Word reading same backward as forward',
          'Racecar and kayak are palindromes.',
        ),
        WordDef(
          'MNEMONIC',
          'Pattern of letters aiding memory retention',
          'Clever memory retention mnemonic.',
        ),
        WordDef(
          'HYPERBOLE',
          'Exaggerated statements not meant to be taken literally',
          'Im so hungry I could eat horse hyperbole.',
        ),
      ],
    ),

    // 10. Professional
    ChapterDef(
      id: 10,
      key: 'professional',
      title: 'Professional',
      iconAsset: 'assets/chapter_images/professional.png',
      themeColor: 0xFF607D8B,
      shortWords: const [
        WordDef(
          'WORK',
          'Activity involving mental or physical effort',
          'Completing the daily corporate work.',
        ),
        WordDef(
          'DESK',
          'Piece of furniture with flat surface for work',
          'Organized office computer work desk.',
        ),
        WordDef(
          'GOAL',
          'Object of a persons ambition or effort',
          'Reaching the quarterly sales goal.',
        ),
        WordDef(
          'TEAM',
          'Group of people working together for purpose',
          'Collaborative project sprint team.',
        ),
        WordDef(
          'PLAN',
          'Detailed proposal for achieving an objective',
          'Strategic business growth plan.',
        ),
        WordDef(
          'LEAD',
          'Be in charge or command of an organization',
          'Leading teams with empathy and vision.',
        ),
        WordDef(
          'HIRE',
          'Employ someone for wages or salary',
          'Hiring top engineering talent.',
        ),
        WordDef(
          'TASK',
          'Piece of work to be done or undertaken',
          'Completing assigned project tasks.',
        ),
        WordDef(
          'MEET',
          'Come into presence of others for discussion',
          'Meeting clients in conference room.',
        ),
        WordDef(
          'DEAL',
          'Agreement reached by negotiation',
          'Closing a multimillion dollar deal.',
        ),
        WordDef(
          'FIRM',
          'Business concern or enterprise partnership',
          'Leading corporate legal law firm.',
        ),
        WordDef(
          'ROLE',
          'Function assumed by a person in business',
          'Assuming product manager role.',
        ),
        WordDef(
          'RISK',
          'Situation involving exposure to danger or loss',
          'Managing commercial venture risk.',
        ),
        WordDef(
          'FUND',
          'Sum of money saved or made available for purpose',
          'Venture capital investment fund.',
        ),
        WordDef(
          'GROW',
          'Increase in size, revenue, or importance',
          'Helping startups grow rapidly.',
        ),
        WordDef(
          'SIGN',
          'Write ones signature on an agreement',
          'Signing the official vendor contract.',
        ),
        WordDef(
          'DATA',
          'Facts and statistics collected for analysis',
          'Analyzing market performance data.',
        ),
        WordDef(
          'COST',
          'Amount of money required to buy or produce',
          'Optimizing company operating cost.',
        ),
        WordDef(
          'RANK',
          'Position in hierarchy of an organization',
          'Rising through senior corporate ranks.',
        ),
        WordDef(
          'GAIN',
          'Increase in wealth or strategic advantage',
          'Achieving annual revenue gain.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'OFFICE',
          'Room or building used for commercial work',
          'Downtown modern corporate office.',
        ),
        WordDef(
          'CAREER',
          'Occupation undertaken for significant period',
          'Building a rewarding medical career.',
        ),
        WordDef(
          'CLIENT',
          'Person or organization using professional services',
          'Presenting proposal to enterprise client.',
        ),
        WordDef(
          'REPORT',
          'Spoken or written account of something investigated',
          'Annual corporate financial report.',
        ),
        WordDef(
          'SALARY',
          'Fixed regular payment made by employer to employee',
          'Competitive salary and bonus package.',
        ),
        WordDef(
          'RESUME',
          'Summary of ones education and work experience',
          'Submitting updated job resume.',
        ),
        WordDef(
          'BUDGET',
          'Estimate of income and expenditure for set period',
          'Allocating the annual marketing budget.',
        ),
        WordDef(
          'EXPERT',
          'Person with extensive knowledge in subject',
          'Consulting an industry expert.',
        ),
        WordDef(
          'MARKET',
          'Arena of commercial dealings and consumers',
          'Analyzing global financial market.',
        ),
        WordDef(
          'LEADER',
          'Person who leads or commands a team',
          'Visionary executive business leader.',
        ),
        WordDef(
          'ETHICS',
          'Moral principles that govern behavior',
          'Upholding strict professional ethics.',
        ),
        WordDef(
          'VISION',
          'Ability to plan future with imagination',
          'Company five-year strategic vision.',
        ),
        WordDef(
          'POLICY',
          'Course of action adopted by organization',
          'Reviewing workplace safety policy.',
        ),
        WordDef(
          'BRANCH',
          'Division of a business operating in specific area',
          'Opening a new regional bank branch.',
        ),
        WordDef(
          'VENDOR',
          'Person or company offering goods for sale',
          'Partnering with certified software vendor.',
        ),
        WordDef(
          'AGENCY',
          'Business providing a particular service',
          'Creative digital advertising agency.',
        ),
        WordDef(
          'EQUITY',
          'Value of the shares issued by a company',
          'Employee stock options and equity.',
        ),
        WordDef(
          'SECTOR',
          'Area or portion of the economy',
          'Booming renewable technology sector.',
        ),
        WordDef(
          'SUMMIT',
          'Meeting of high-level leaders or experts',
          'Attending global business summit.',
        ),
        WordDef(
          'AGENDA',
          'List of items to be discussed at formal meeting',
          'Reviewing the board meeting agenda.',
        ),
      ],
      longWords: const [
        WordDef(
          'LEADERSHIP',
          'The action of leading a group of people',
          'Exemplary visionary leadership style.',
        ),
        WordDef(
          'MANAGEMENT',
          'Process of dealing with or controlling things',
          'Effective agile project management.',
        ),
        WordDef(
          'EXECUTIVE',
          'Person with senior managerial responsibility',
          'Chief executive officer of firm.',
        ),
        WordDef(
          'INNOVATION',
          'Action or process of innovating new methods',
          'Fostering continuous tech innovation.',
        ),
        WordDef(
          'STRATEGY',
          'High level plan to achieve business goals',
          'Long-term corporate growth strategy.',
        ),
        WordDef(
          'ENTERPRISE',
          'A business or company undertaking',
          'Global cloud enterprise solutions.',
        ),
        WordDef(
          'CONFERENCE',
          'Formal meeting for discussion and consultation',
          'Keynote address at tech conference.',
        ),
        WordDef(
          'CONSULTANT',
          'Professional providing expert advice in field',
          'Senior management strategy consultant.',
        ),
        WordDef(
          'NEGOTIATION',
          'Discussion aimed at reaching an agreement',
          'Successful contractual negotiation.',
        ),
        WordDef(
          'PRESENTATION',
          'Giving speech showcasing ideas to audience',
          'Delivering pitch deck presentation.',
        ),
        WordDef(
          'COLLEAGUE',
          'Person with whom one works in profession',
          'Collaborating with trusted colleague.',
        ),
        WordDef(
          'INVESTMENT',
          'Action of investing money for profit return',
          'Smart venture capital investment.',
        ),
        WordDef(
          'PRODUCTIVITY',
          'State of producing significant results',
          'Boosting team daily productivity.',
        ),
        WordDef(
          'CORPORATION',
          'Large company authorized to act as single entity',
          'Multinational tech corporation.',
        ),
        WordDef(
          'CERTIFICATION',
          'Action of providing official document of status',
          'Passing professional certification.',
        ),
        WordDef(
          'PARTNERSHIP',
          'Association of two or more entities in business',
          'Strategic cross-border partnership.',
        ),
        WordDef(
          'COMPLIANCE',
          'Action of complying with official regulations',
          'Adhering to regulatory compliance.',
        ),
        WordDef(
          'DEVELOPMENT',
          'Process of developing products and skills',
          'Professional career development.',
        ),
        WordDef(
          'HEADQUARTERS',
          'Main offices of an organization',
          'Company global headquarters campus.',
        ),
        WordDef(
          'ENTREPRENEUR',
          'Person setting up businesses taking financial risks',
          'Innovative tech startup entrepreneur.',
        ),
      ],
    ),

    // 11. Religion
    ChapterDef(
      id: 11,
      key: 'religion',
      title: 'Religion',
      iconAsset: 'assets/chapter_images/religion.png',
      themeColor: 0xFF8D6E63,
      shortWords: const [
        WordDef(
          'PRAY',
          'Address a solemn request or expression of thanks',
          'Bowing heads together to pray.',
        ),
        WordDef(
          'HOPE',
          'Feeling of expectation and desire for certain thing',
          'Holding faith and enduring hope.',
        ),
        WordDef(
          'SOUL',
          'The spiritual or immaterial part of a human being',
          'Nourishing peace in the soul.',
        ),
        WordDef(
          'HOLY',
          'Dedicated or consecrated to God or religious purpose',
          'Visiting ancient holy pilgrimage sites.',
        ),
        WordDef(
          'MONK',
          'Member of a religious community of men under vows',
          'Buddhist monk meditating quietly.',
        ),
        WordDef(
          'PEACE',
          'Freedom from disturbance and state of tranquility',
          'May divine blessings bring peace.',
        ),
        WordDef(
          'ALTAR',
          'Table or flat-topped block used as religious focus',
          'Flowers placed before the altar.',
        ),
        WordDef(
          'FAITH',
          'Complete trust or confidence in spiritual beliefs',
          'Unwavering strength through faith.',
        ),
        WordDef(
          'CHURCH',
          'Building used for public Christian worship',
          'Historic gothic stone cathedral church.',
        ),
        WordDef(
          'TEMPLE',
          'Building devoted to the worship of a god',
          'Ancient Hindu mountain temple.',
        ),
        WordDef(
          'HYMN',
          'Religious song or poem of praise',
          'Choir singing melodic church hymns.',
        ),
        WordDef(
          'BELL',
          'Hollow metal instrument ringing in church belfry',
          'Cathedral bells ringing on Sunday.',
        ),
        WordDef(
          'CROSS',
          'Religious emblem shaped like intersecting beams',
          'Golden decorative cross pendant.',
        ),
        WordDef(
          'GURU',
          'Spiritual teacher in Hinduism and Buddhism',
          'Seeking wisdom from meditation guru.',
        ),
        WordDef(
          'SAGE',
          'Profoundly wise person especially in philosophy',
          'Words of wisdom from ancient sage.',
        ),
        WordDef(
          'ZEAL',
          'Great energy or enthusiasm in pursuit of cause',
          'Spiritual devotion and holy zeal.',
        ),
        WordDef(
          'ROBE',
          'Long, loose outer garment worn by clergy',
          'Silk ceremonial saffron robe.',
        ),
        WordDef(
          'DOME',
          'Rounded vault forming the roof of a building',
          'Golden illuminated mosque dome.',
        ),
        WordDef(
          'PALM',
          'Symbol of victory and peace in religious art',
          'Waving palm fronds in procession.',
        ),
        WordDef(
          'FAST',
          'Abstaining from food or drink as religious practice',
          'Observing sacred daylight fast.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'PRAYER',
          'Solemn request for help or expression of thanks',
          'Morning recitation of daily prayer.',
        ),
        WordDef(
          'TEMPLE',
          'Building dedicated to worship in Eastern religions',
          'Tranquil Buddhist Kyoto temple.',
        ),
        WordDef(
          'SACRED',
          'Connected with God or dedicated to a religious purpose',
          'Revering the sacred holy scriptures.',
        ),
        WordDef(
          'DIVINE',
          'Of, from, or like God or a higher power',
          'Experiencing radiant divine grace.',
        ),
        WordDef(
          'PILGRIM',
          'Person who journeys to a sacred place for religion',
          'Pilgrim walking along ancient path.',
        ),
        WordDef(
          'SHRINE',
          'Holy place associated with sacred person or relic',
          'Lighting candles at wayside shrine.',
        ),
        WordDef(
          'RITUAL',
          'Religious ceremony consisting of series of actions',
          'Traditional sacred evening ritual.',
        ),
        WordDef(
          'BELIEF',
          'Acceptance that something exists or is true',
          'Deeply rooted spiritual belief.',
        ),
        WordDef(
          'HEAVEN',
          'Place regarded in religions as abode of God',
          'Visions of radiant golden heaven.',
        ),
        WordDef(
          'BISHOP',
          'Senior member of Christian clergy in charge of diocese',
          'Ordination ceremony for new bishop.',
        ),
        WordDef(
          'PRIEST',
          'Ordained minister having authority to administer rites',
          'Parish priest blessing congregation.',
        ),
        WordDef(
          'MOSQUE',
          'Muslim place of worship with minarets',
          'Marble tiled grand Friday mosque.',
        ),
        WordDef(
          'MINARET',
          'Slender tower with balcony for call to prayer',
          'Tall minaret soaring into blue sky.',
        ),
        WordDef(
          'VESPERS',
          'Service of evening prayer in Christian churches',
          'Chanting choral evening vespers.',
        ),
        WordDef(
          'ROCHET',
          'White vestment worn by bishops and abbots',
          'Embroidered linen white rochet.',
        ),
        WordDef(
          'ROSARY',
          'String of beads used for keeping count of prayers',
          'Holding wooden meditation rosary.',
        ),
        WordDef(
          'GOSPEL',
          'The teaching or revelation of Christ',
          'Reading the four gospel books.',
        ),
        WordDef(
          'CHALICE',
          'Large cup or goblet used in holy communion',
          'Gilded golden sacramental chalice.',
        ),
        WordDef(
          'PARSON',
          'Beneficed member of the clergy',
          'Country village parson at church.',
        ),
        WordDef(
          'SPIRIT',
          'The non-physical part of a person',
          'Uplifting the human spirit.',
        ),
      ],
      longWords: const [
        WordDef(
          'SANCTUARY',
          'A holy place; a sacred place of worship',
          'Seeking quiet peace in the sanctuary.',
        ),
        WordDef(
          'MEDITATION',
          'Practice of focusing mind to achieve calm clarity',
          'Daily mindfulness breath meditation.',
        ),
        WordDef(
          'SCRIPTURE',
          'The sacred writings of Christianity or religion',
          'Studying ancient revealed scripture.',
        ),
        WordDef(
          'MONASTERY',
          'Building occupied by a community of monks',
          'Remote mountaintop stone monastery.',
        ),
        WordDef(
          'BLESSING',
          'Gods favor and protection pronounced on person',
          'Receiving the priests blessing.',
        ),
        WordDef(
          'PILGRIMAGE',
          'A pilgrims journey to a sacred location',
          'Annual spiritual holy pilgrimage.',
        ),
        WordDef(
          'SPIRITUALITY',
          'Quality of being concerned with human spirit',
          'Deep personal inner spirituality.',
        ),
        WordDef(
          'COMPASSION',
          'Sympathetic pity and concern for the sufferings',
          'Showing boundless loving compassion.',
        ),
        WordDef(
          'ENLIGHTENMENT',
          'State of having attained spiritual knowledge',
          'Buddha attaining full enlightenment.',
        ),
        WordDef(
          'DEVOTION',
          'Love, loyalty, or enthusiasm for a cause or god',
          'Lifelong dedicated holy devotion.',
        ),
        WordDef(
          'CATHEDRAL',
          'The principal church of a diocese with bishop',
          'Historic Gothic Notre Dame cathedral.',
        ),
        WordDef(
          'RESURRECTION',
          'Revival or bringing back to life after death',
          'Celebrating Easter resurrection.',
        ),
        WordDef(
          'BENEDICTION',
          'The utterance of a blessing at religious service',
          'Pronouncing final benediction.',
        ),
        WordDef(
          'TABERNACLE',
          'Sanctuary or tent used as place of worship',
          'Carved wooden altar tabernacle.',
        ),
        WordDef(
          'CONSECRATION',
          'Action of declaring something sacred or holy',
          'Solemn solemn church consecration.',
        ),
        WordDef(
          'WORSHIPPER',
          'Person who attends religious service and worships',
          'Devout humble temple worshipper.',
        ),
        WordDef(
          'CONGREGATION',
          'Group of people assembled for religious worship',
          'Singing hymns with congregation.',
        ),
        WordDef(
          'RIGHTEOUSNESS',
          'Quality of being morally right and justifiable',
          'Pursuing truth and righteousness.',
        ),
        WordDef(
          'TRANSCENDENCE',
          'Existence or experience beyond normal physical level',
          'Spiritual awe and transcendence.',
        ),
        WordDef(
          'FORGIVENESS',
          'Action of forgiving or being forgiven for error',
          'Extending heartfelt forgiveness.',
        ),
      ],
    ),

    // 12. Music
    ChapterDef(
      id: 12,
      key: 'music',
      title: 'Music',
      iconAsset: 'assets/chapter_images/music.png',
      themeColor: 0xFFE91E63,
      shortWords: const [
        WordDef(
          'BEAT',
          'Main accent or rhythmic unit in music or poetry',
          'Catchy steady drum rhythm beat.',
        ),
        WordDef(
          'TUNE',
          'Melody that is easy to remember and sing',
          'Humming a cheerful morning tune.',
        ),
        WordDef(
          'SONG',
          'Short poem or set of words set to music',
          'Singing a sweet acoustic love song.',
        ),
        WordDef(
          'NOTE',
          'Single tone of definite pitch made by instrument',
          'Playing a clear high musical note.',
        ),
        WordDef(
          'BASS',
          'Lowest part in musical harmony or low instrument',
          'Deep thumping electric bass line.',
        ),
        WordDef(
          'DRUM',
          'Percussion instrument sounded by striking membrane',
          'Snare drum keeping the tempo.',
        ),
        WordDef(
          'BAND',
          'Small musical group playing popular or rock music',
          'Live indie rock band on stage.',
        ),
        WordDef(
          'SOLO',
          'Musical piece or section performed by one person',
          'Blistering electric guitar solo.',
        ),
        WordDef(
          'JAZZ',
          'Music genre originating in African American communities',
          'Smooth improvisational jazz trio.',
        ),
        WordDef(
          'ROCK',
          'Music genre characterized by strong rhythm and guitars',
          'High-energy classic rock anthem.',
        ),
        WordDef(
          'HORN',
          'Brass wind instrument with a flared bell',
          'French horn playing rich brass harmony.',
        ),
        WordDef(
          'HARP',
          'Musical instrument with strings played with fingers',
          'Angelic plucked gold string harp.',
        ),
        WordDef(
          'LUTE',
          'Plucked string instrument with pear-shaped body',
          'Renaissance minstrel playing lute.',
        ),
        WordDef(
          'REED',
          'Thin strip of cane vibrating to produce sound in wind',
          'Saxophone wooden mouthpiece reed.',
        ),
        WordDef(
          'DUET',
          'Performance by two singers, musicians, or dancers',
          'Vocal duet harmonizing together.',
        ),
        WordDef(
          'CHORD',
          'Group of notes sounded together in harmony',
          'Strumming a major acoustic chord.',
        ),
        WordDef(
          'PITCH',
          'Quality of a sound governed by frequency of vibrations',
          'Singing with perfect pitch accuracy.',
        ),
        WordDef(
          'KEY',
          'System of musical notes based on a particular note',
          'Sonata written in the key of C major.',
        ),
        WordDef(
          'REST',
          'Interval of silence between notes in music score',
          'Two-beat musical silence rest.',
        ),
        WordDef(
          'BLUES',
          'Melancholic music genre originating in Deep South',
          'Soulful delta blues acoustic guitar.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'VIOLIN',
          'Stringed musical instrument played with a bow',
          'Virtuoso playing a Stradivarius violin.',
        ),
        WordDef(
          'GUITAR',
          'Stringed instrument played by plucking or strumming',
          'Strumming a Spanish classical guitar.',
        ),
        WordDef(
          'MELODY',
          'Sequence of single notes that is musically satisfying',
          'Catchy unforgettable vocal melody.',
        ),
        WordDef(
          'RHYTHM',
          'Strong, regular, repeated pattern of movement or sound',
          'Dancing to the lively salsa rhythm.',
        ),
        WordDef(
          'ALBUM',
          'Collection of audio recordings issued as a collection',
          'Listening to the artist debut album.',
        ),
        WordDef(
          'OPERA',
          'Dramatic work in one or more acts set to music',
          'Attending Italian grand opera gala.',
        ),
        WordDef(
          'CHORUS',
          'Part of a song that is repeated after verses',
          'Crowd singing along to the chorus.',
        ),
        WordDef(
          'LYRICS',
          'The words of a song written for performance',
          'Poetic meaningful song lyrics.',
        ),
        WordDef(
          'PIANO',
          'Large keyboard instrument with hammers and strings',
          'Playing classical grand piano chords.',
        ),
        WordDef(
          'FLUTE',
          'High-pitched wind instrument played by blowing across',
          'Sweet melodic silver concert flute.',
        ),
        WordDef(
          'CELLO',
          'Large stringed instrument held between the knees',
          'Rich resonant warm cello sound.',
        ),
        WordDef(
          'TEMPO',
          'The speed at which a passage of music is played',
          'Increasing the tempo to allegro.',
        ),
        WordDef(
          'BRASS',
          'Wind instruments made of brass such as trumpet',
          'Loud fanfares from the brass section.',
        ),
        WordDef(
          'SONATA',
          'Composition for an instrumental soloist with piano',
          'Beethoven Moonlight piano sonata.',
        ),
        WordDef(
          'ACOUSTIC',
          'Instruments that produce sound without electricity',
          'Warm acoustic guitar unplugged set.',
        ),
        WordDef(
          'TREBLE',
          'High pitch in musical range; soprano clef',
          'Treble clef at start of sheet music.',
        ),
        WordDef(
          'RHYME',
          'Words sounding identical at end of lines',
          'Song lyrics written with sweet rhyme.',
        ),
        WordDef(
          'BALLAD',
          'Slow sentimental or romantic popular song',
          'Emotional heartfelt piano ballad.',
        ),
        WordDef(
          'DISCO',
          'Pop music intended for dancing to in clubs',
          'Groovy 70s glittering disco beat.',
        ),
        WordDef(
          'CYMBAL',
          'Concave brass plate struck with a drumstick',
          'Crashing high-hat drum cymbal.',
        ),
      ],
      longWords: const [
        WordDef(
          'ORCHESTRA',
          'Large group of musicians playing diverse instruments',
          'Symphony orchestra performing live.',
        ),
        WordDef(
          'SYMPHONY',
          'Elaborate musical composition for full orchestra',
          'Beethovens Ninth master symphony.',
        ),
        WordDef(
          'SAXOPHONE',
          'Brass wind instrument with a single-reed mouthpiece',
          'Soulful tenor saxophone jazz riff.',
        ),
        WordDef(
          'MICROPHONE',
          'Audio equipment capturing vocal performances',
          'Singing into dynamic stage microphone.',
        ),
        WordDef(
          'HARMONICA',
          'Small wind instrument played with the mouth',
          'Blues harmonica pocket instrument.',
        ),
        WordDef(
          'COMPOSITION',
          'A work of music, literature, or art',
          'Original classical string composition.',
        ),
        WordDef(
          'PERCUSSION',
          'Musical instruments played by striking with stick',
          'Timpani and drums percussion section.',
        ),
        WordDef(
          'INSTRUMENT',
          'Object or device for producing musical sounds',
          'Learning to play a musical instrument.',
        ),
        WordDef(
          'CONDUCTOR',
          'Leader directing performance of an orchestra',
          'Orchestra conductor waving baton.',
        ),
        WordDef(
          'HEADPHONES',
          'Pair of small loudspeakers worn over the ears',
          'Studio monitoring sound headphones.',
        ),
        WordDef(
          'METRONOME',
          'Device marking time at regular intervals by ticking',
          'Practicing piano scales with metronome.',
        ),
        WordDef(
          'ACCORDION',
          'Portable musical instrument with bellows and keys',
          'Traditional French folk accordion.',
        ),
        WordDef(
          'TROMBONE',
          'Large brass wind instrument with a sliding tube',
          'Slide trombone brass section melody.',
        ),
        WordDef(
          'HARMONIOUS',
          'Forming a pleasing or consistent whole in sound',
          'Harmonious choral choir voices.',
        ),
        WordDef(
          'IMPROVISE',
          'Create and perform music spontaneously without prep',
          'Jazz trumpet player improvising solos.',
        ),
        WordDef(
          'SYNTHESIZER',
          'Electronic musical instrument generating sounds',
          'Analog electronic keyboard synthesizer.',
        ),
        WordDef(
          'CRESCENDO',
          'Gradual increase in loudness in a piece of music',
          'Powerful orchestral crescendo climax.',
        ),
        WordDef(
          'SOUNDTRACK',
          'The music accompanying a film or television show',
          'Epic cinematic movie soundtrack.',
        ),
        WordDef(
          'AMPLIFIER',
          'Electronic device for increasing volume of sound',
          'Guitar plugged into tube amplifier.',
        ),
        WordDef(
          'TAMBOURINE',
          'Percussion instrument with metallic jingles',
          'Shaking wooden rhythm tambourine.',
        ),
      ],
    ),

    // 13. Hobby
    ChapterDef(
      id: 13,
      key: 'hobby',
      title: 'Hobby',
      iconAsset: 'assets/chapter_images/hobby.png',
      themeColor: 0xFFFF5722,
      shortWords: const [
        WordDef(
          'SEW',
          'Join or fasten by making stitches with needle',
          'Learning to sew custom clothes.',
        ),
        WordDef(
          'KNIT',
          'Make garment by interlocking loops of wool with needles',
          'Knitting warm wool winter scarves.',
        ),
        WordDef(
          'COOK',
          'Prepare food by combining ingredients and heating',
          'Loving to cook gourmet dinners.',
        ),
        WordDef(
          'BAKE',
          'Cook food by dry heat in an oven',
          'Baking fresh sourdough bread loaves.',
        ),
        WordDef(
          'FISH',
          'Catch fish with a rod, net, or line',
          'Fishing quietly by the lake at dawn.',
        ),
        WordDef(
          'HIKE',
          'Walk a long distance especially across country',
          'Hiking mountain trails in autumn.',
        ),
        WordDef(
          'CAMP',
          'Live in a tent or temporary shelter outdoors',
          'Camping under the starry night sky.',
        ),
        WordDef(
          'DRAW',
          'Produce pictures with pencil, pen, or crayon',
          'Drawing portraits in sketchbook.',
        ),
        WordDef(
          'READ',
          'Look at and comprehend written texts in books',
          'Reading fiction novels on weekends.',
        ),
        WordDef(
          'YARN',
          'Spun thread used for knitting and weaving',
          'Colorful soft merino wool yarn balls.',
        ),
        WordDef(
          'BEAD',
          'Small piece of glass or stone pierced for threading',
          'Making jewelry with crystal beads.',
        ),
        WordDef(
          'COIN',
          'Flat metal disc used as money, collected as hobby',
          'Collecting rare vintage silver coins.',
        ),
        WordDef(
          'GAME',
          'Activity engaged in for leisure and amusement',
          'Board game evening with friends.',
        ),
        WordDef(
          'SWIM',
          'Propel oneself through water using limbs',
          'Swimming morning laps in pool.',
        ),
        WordDef(
          'CLIMB',
          'Go up or ascend a mountain or rock wall',
          'Rock climbing indoor gym wall.',
        ),
        WordDef(
          'RUN',
          'Move at a speed faster than a walk',
          'Running morning 5K road race.',
        ),
        WordDef(
          'SURF',
          'Ride a wave toward the shore on a board',
          'Surfing big ocean swell waves.',
        ),
        WordDef(
          'DIVE',
          'Plunge head first into water or explore depths',
          'Scuba diving coral reef lagoon.',
        ),
        WordDef(
          'BIKE',
          'Ride a bicycle for recreation or exercise',
          'Riding mountain bike through forest.',
        ),
        WordDef(
          'SAIL',
          'Travel in a boat with sails across water',
          'Sailing a white sloop on the bay.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'GARDEN',
          'Cultivating plants, flowers, and vegetables',
          'Growing organic tomatoes in garden.',
        ),
        WordDef(
          'SEWING',
          'Activity of joining cloth with needle and thread',
          'Custom dressmaking and sewing.',
        ),
        WordDef(
          'PUZZLE',
          'Game testing mental ingenuity and pattern finding',
          'Assembling a 1000-piece jigsaw puzzle.',
        ),
        WordDef(
          'GAMING',
          'Playing interactive digital and video games',
          'Weekend PC and console gaming.',
        ),
        WordDef(
          'HIKING',
          'Walking long distances across nature trails',
          'Weekend hiking in national parks.',
        ),
        WordDef(
          'CAMPING',
          'Outdoor recreation sleeping in tents',
          'Setting up wilderness camping site.',
        ),
        WordDef(
          'FISHING',
          'Sport of catching fish in rivers and lakes',
          'Fly fishing in crystal clear streams.',
        ),
        WordDef(
          'POTTERY',
          'Ceramic pots and vessels made by hand with clay',
          'Shaping clay vases on pottery wheel.',
        ),
        WordDef(
          'BAKING',
          'Culinary craft of making bread, cakes, and pies',
          'Sunday afternoon cookie baking.',
        ),
        WordDef(
          'ORIGAMI',
          'Japanese art of folding paper into shapes',
          'Folding delicate paper origami crane.',
        ),
        WordDef(
          'CHESS',
          'Two-player strategic board game of kings',
          'Studying classic chess grandmaster openings.',
        ),
        WordDef(
          'RUNNING',
          'Sport of moving rapidly on foot for fitness',
          'Training for a city marathon running.',
        ),
        WordDef(
          'CYCLING',
          'Riding bicycles for sport or recreation',
          'Road cycling through country hills.',
        ),
        WordDef(
          'DIVING',
          'Exploring underwater ocean worlds with gear',
          'Deep sea scuba diving adventure.',
        ),
        WordDef(
          'SKATING',
          'Gliding on ice or wheeled roller skates',
          'Winter figure ice skating on rink.',
        ),
        WordDef(
          'SINGING',
          'Producing musical sounds with the voice',
          'Singing in community choir harmony.',
        ),
        WordDef(
          'DANCING',
          'Moving rhythmically to music with steps',
          'Taking ballroom and salsa dancing classes.',
        ),
        WordDef(
          'ROWING',
          'Propelling a boat with oars on water',
          'Morning sculling rowing on the river.',
        ),
        WordDef(
          'JOGGING',
          'Running at a steady gentle pace for health',
          'Morning jogging around city park.',
        ),
        WordDef(
          'CRAFT',
          'Making artistic decorative objects by hand',
          'Handcrafted leather goods craft.',
        ),
      ],
      longWords: const [
        WordDef(
          'PHOTOGRAPHY',
          'Art and hobby of capturing images on cameras',
          'Landscape and portrait photography.',
        ),
        WordDef(
          'WOODWORKING',
          'Craft of building furniture and objects from wood',
          'Building oak tables in woodworking shop.',
        ),
        WordDef(
          'CALLIGRAPHY',
          'Art of decorative artistic lettering with pens',
          'Practicing copperplate script calligraphy.',
        ),
        WordDef(
          'BIRD WATCHING',
          'Hobby of observing birds in natural habitats',
          'Binoculars for morning bird watching.',
        ),
        WordDef(
          'SCRAPBOOK',
          'Album for preserving photos and memorabilia',
          'Creating a family holiday scrapbook.',
        ),
        WordDef(
          'EMBROIDERY',
          'Art of decorating fabric with needle stitched thread',
          'Intricate floral silk thread embroidery.',
        ),
        WordDef(
          'ASTRONOMY',
          'Observing stars, planets, and celestial bodies',
          'Stargazing with telescope astronomy.',
        ),
        WordDef(
          'COLLECTING',
          'Hobby of gathering specific items of interest',
          'Stamp and vintage postcard collecting.',
        ),
        WordDef(
          'SKATEBOARD',
          'Riding a narrow board on wheels performing tricks',
          'Street skateboarding at local skate park.',
        ),
        WordDef(
          'SNOWBOARDING',
          'Sliding down snow-covered slopes on a board',
          'Winter alpine resort snowboarding.',
        ),
        WordDef(
          'MOUNTAINEER',
          'Person climbing mountains as sport or hobby',
          'Equipped alpine mountaineer climbing.',
        ),
        WordDef(
          'PHILATELY',
          'The collection and study of postage stamps',
          'Rare vintage stamp philately collection.',
        ),
        WordDef(
          'LEATHERCRAFT',
          'Craft of making leather goods and accessories',
          'Hand-stitching leathercraft wallets.',
        ),
        WordDef(
          'BREADMAKING',
          'Art of mixing dough and baking fresh bread',
          'Artisan sourdough breadmaking course.',
        ),
        WordDef(
          'GEOCACHING',
          'Outdoor treasure hunting using GPS coordinates',
          'Finding hidden containers in geocaching.',
        ),
        WordDef(
          'WATERCOLOR',
          'Painting using water-soluble pigment washes',
          'Loose floral watercolor sketchbook.',
        ),
        WordDef(
          'BEE KEEPING',
          'Hobby of maintaining honeybee colonies in hives',
          'Harvesting raw honey in bee keeping.',
        ),
        WordDef(
          'AQUARIUM',
          'Keeping freshwater or marine fish in glass tanks',
          'Planted tropical freshwater aquarium.',
        ),
        WordDef(
          'MODELING',
          'Building miniature replicas of planes or cars',
          'Assembling scale plastic kit modeling.',
        ),
        WordDef(
          'CALLISTHENIC',
          'Gymnastic bodyweight exercises for fitness',
          'Outdoor park callisthenic workouts.',
        ),
      ],
    ),

    // 14. Nature
    ChapterDef(
      id: 14,
      key: 'nature',
      title: 'Nature',
      iconAsset: 'assets/chapter_images/nature.png',
      themeColor: 0xFF2E7D32,
      shortWords: const [
        WordDef(
          'TREE',
          'Woody perennial plant with trunk and canopy',
          'Ancient sequoia giant redwood tree.',
        ),
        WordDef(
          'RIVER',
          'Large natural stream of water flowing to sea',
          'Clear mountain river flowing downstream.',
        ),
        WordDef(
          'OCEAN',
          'Vast body of salt water covering earth',
          'Waves rolling across the vast blue ocean.',
        ),
        WordDef(
          'LAKE',
          'Large body of water surrounded by land',
          'Tranquil mirror lake reflecting mountains.',
        ),
        WordDef(
          'POND',
          'Small body of still water formed naturally',
          'Water lilies floating on garden pond.',
        ),
        WordDef(
          'ROCK',
          'Solid mineral material forming part of earth',
          'Sturdy granite boulder rock ledge.',
        ),
        WordDef(
          'SAND',
          'Granular material composed of rock and mineral',
          'Soft warm golden beach ocean sand.',
        ),
        WordDef(
          'RAIN',
          'Moisture condensed from the atmosphere falling in drops',
          'Cool refreshing spring rain showers.',
        ),
        WordDef(
          'SNOW',
          'Atmospheric water vapor frozen into crystals',
          'Fresh powdery white mountain snow.',
        ),
        WordDef(
          'WIND',
          'Perceptible natural movement of the air',
          'Gentle cooling breeze wind in trees.',
        ),
        WordDef(
          'HILL',
          'Naturally raised area of land, lower than mountain',
          'Rolling green grassy countryside hills.',
        ),
        WordDef(
          'VALE',
          'A valley, often used in poetic contexts',
          'Peaceful green shaded river vale.',
        ),
        WordDef(
          'CAVE',
          'Natural underground chamber in hillside',
          'Exploring limestone stalactite cave.',
        ),
        WordDef(
          'SOIL',
          'Upper layer of earth in which plants grow',
          'Rich fertile loam organic soil.',
        ),
        WordDef(
          'FERN',
          'Flowerless plant with feathery green fronds',
          'Lush woodland forest floor fern.',
        ),
        WordDef(
          'MOSS',
          'Soft green velvety plant growing in damp places',
          'Green moss coating river boulders.',
        ),
        WordDef(
          'BARK',
          'Tough protective outer covering of tree trunks',
          'Rough textured aromatic pine bark.',
        ),
        WordDef(
          'PEAK',
          'Pointed top of a mountain or ridge',
          'Snow-covered jagged alpine peak.',
        ),
        WordDef(
          'DUNE',
          'Mound or ridge of sand formed by wind',
          'Towering Sahara desert sand dunes.',
        ),
        WordDef(
          'REEF',
          'Ridge of jagged rock, coral, or sand at sea',
          'Colorful tropical coral marine reef.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'FOREST',
          'Large area covered chiefly with trees and undergrowth',
          'Deep evergreen temperate rain forest.',
        ),
        WordDef(
          'VALLEY',
          'Low area of land between hills or mountains',
          'Lush green agricultural fertile valley.',
        ),
        WordDef(
          'CANYON',
          'Deep gorge with steep sides carved by river',
          'Grand Canyon red sandstone gorge.',
        ),
        WordDef(
          'DESERT',
          'Barren area of land where little precipitation occurs',
          'Vast arid sun-drenched sandy desert.',
        ),
        WordDef(
          'ISLAND',
          'Piece of land surrounded on all sides by water',
          'Tropical volcanic island paradise.',
        ),
        WordDef(
          'STREAM',
          'Small narrow river of running fresh water',
          'Babbling crystal clear forest stream.',
        ),
        WordDef(
          'SUNSET',
          'Daily disappearance of the sun below horizon',
          'Brilliant fiery orange coastal sunset.',
        ),
        WordDef(
          'SUNRISE',
          'Time in the morning when the sun appears',
          'Watching golden dawn sunrise on peaks.',
        ),
        WordDef(
          'MEADOW',
          'Piece of grassland especially used for pasture',
          'Wildflower blooming alpine meadow.',
        ),
        WordDef(
          'JUNGLE',
          'Land overgrown with dense tropical vegetation',
          'Humid biodiverse Amazonian jungle.',
        ),
        WordDef(
          'GLACIER',
          'Slowly moving mass or river of ice formed on mountains',
          'Massive blue polar ice glacier.',
        ),
        WordDef(
          'SPRING',
          'Place where water or oil wells up from earth',
          'Natural mineral thermal hot spring.',
        ),
        WordDef(
          'AUTUMN',
          'Season between summer and winter with falling leaves',
          'Golden red foliage of crisp autumn.',
        ),
        WordDef(
          'SUMMER',
          'The warmest season of the year',
          'Sunny long warm daylight summer days.',
        ),
        WordDef(
          'WINTER',
          'The coldest season of the year with ice',
          'Snow-covered frosted winter landscape.',
        ),
        WordDef(
          'LAGOON',
          'Stretch of salt water separated from sea by reef',
          'Turquoise tropical island coral lagoon.',
        ),
        WordDef(
          'SHORES',
          'Land along the edge of a sea, lake, or river',
          'Walking along pebbled ocean shores.',
        ),
        WordDef(
          'CLIFFS',
          'Steep high faces of rock on coast or mountain',
          'Towering white chalk ocean sea cliffs.',
        ),
        WordDef(
          'SWAMPS',
          'Area of low-lying, uncultivated ground where water collects',
          'Mangrove wetland freshwater swamps.',
        ),
        WordDef(
          'NATURE',
          'Physical world and everything in it not made by humans',
          'Protecting pristine wilderness nature.',
        ),
      ],
      longWords: const [
        WordDef(
          'WATERFALL',
          'Cascade of water falling from a height',
          'Towering thundering mountain waterfall.',
        ),
        WordDef(
          'WILDERNESS',
          'Ungridded natural environment undisturbed by man',
          'Expansive untouched arctic wilderness.',
        ),
        WordDef(
          'RAINFOREST',
          'Luxuriant, dense forest rich in biodiversity',
          'Canopy layer of the tropical rainforest.',
        ),
        WordDef(
          'LANDSCAPE',
          'All the visible features of an area of countryside',
          'Breathtaking panoramic mountain landscape.',
        ),
        WordDef(
          'MOUNTAIN',
          'Large natural elevation of earth surface',
          'Climbing the rugged snow-capped mountain.',
        ),
        WordDef(
          'EARTHQUAKE',
          'Sudden violent shaking of the ground',
          'Tectonic plates shifting in earthquake.',
        ),
        WordDef(
          'ECOSYSTEM',
          'Biological community of interacting organisms',
          'Delicate balance of marine ecosystem.',
        ),
        WordDef(
          'ENVIRONMENT',
          'Surroundings or conditions in which organism lives',
          'Preserving our natural environment.',
        ),
        WordDef(
          'VOLCANO',
          'Mountain having a crater through which lava erupts',
          'Active smoking crater volcanic cone.',
        ),
        WordDef(
          'BIODIVERSITY',
          'Variety of plant and animal life in world or habitat',
          'Rich biodiversity of coral reefs.',
        ),
        WordDef(
          'ATMOSPHERE',
          'Envelope of gases surrounding earth or planet',
          'Protecting the ozone layer atmosphere.',
        ),
        WordDef(
          'HORIZON',
          'Line at which the earth surface and sky meet',
          'Ships sailing toward the distant horizon.',
        ),
        WordDef(
          'HURRICANE',
          'Storm with violent wind, in particular tropical cyclone',
          'Category five ocean tropical hurricane.',
        ),
        WordDef(
          'CONSERVATION',
          'Preservation and protection of the natural world',
          'Wildlife habitat ecological conservation.',
        ),
        WordDef(
          'AVALANCHE',
          'Mass of snow, ice, and rocks falling down mountain',
          'Warning sirens for winter avalanche.',
        ),
        WordDef(
          'SANCTUARY',
          'Nature reserve where animals and plants are protected',
          'Wildlife bird and elephant sanctuary.',
        ),
        WordDef(
          'TUNDRA',
          'Vast, flat, treeless Arctic region where subsoil is frozen',
          'Arctic permafrost mossy tundra.',
        ),
        WordDef(
          'PLATEAU',
          'Area of fairly level high ground',
          'Expansive high Colorado red rock plateau.',
        ),
        WordDef(
          'STALACTITE',
          'Tapering structure hanging like icicle from cave ceiling',
          'Limestone dripping cave stalactites.',
        ),
        WordDef(
          'TORNADO',
          'Violently rotating column of air touching ground',
          'Twister spinning across plains tornado.',
        ),
      ],
    ),

    // 15. Tournament
    ChapterDef(
      id: 15,
      key: 'tournament',
      title: 'Tournament',
      iconAsset: 'assets/chapter_images/tournament.png',
      themeColor: 0xFFFFC107,
      shortWords: const [
        WordDef(
          'CUP',
          'Ornamental trophy awarded to tournament winners',
          'Lifting the golden championship cup.',
        ),
        WordDef(
          'WIN',
          'Be successful or victorious in a contest',
          'Playing hard to earn the match win.',
        ),
        WordDef(
          'RACE',
          'Competition between runners, vehicles, or boats',
          'Sprinting the final lap of the race.',
        ),
        WordDef(
          'TEAM',
          'Group of players forming one side in contest',
          'United disciplined tournament team.',
        ),
        WordDef(
          'GAME',
          'Competitive contest played according to rules',
          'Thrilling overtime championship game.',
        ),
        WordDef(
          'GOAL',
          'Object or score aimed at in tournament match',
          'Scoring the winning shootout goal.',
        ),
        WordDef(
          'RANK',
          'Position in hierarchy on official standings',
          'Climbing to number one world rank.',
        ),
        WordDef(
          'SEED',
          'Competitor ranked by skill in tournament draw',
          'Top seeded tournament favorite player.',
        ),
        WordDef(
          'PLAY',
          'Engage in match according to regulations',
          'Fair play and sportsmanship on court.',
        ),
        WordDef(
          'GOLD',
          'Precious metal awarded for first place',
          'Standing on podium with medal of gold.',
        ),
        WordDef(
          'DUEL',
          'Contest with deadly weapons or between two opponents',
          'Epic fencing sword duel on the strip.',
        ),
        WordDef(
          'BOUT',
          'Short period of intense contest such as boxing',
          'Ten-round heavyweight title bout.',
        ),
        WordDef(
          'HEAT',
          'Preliminary round in a race or contest',
          'Winning the qualifying 100m sprint heat.',
        ),
        WordDef(
          'DRAW',
          'Fair allocation of competitors to match brackets',
          'Live broadcast of tournament group draw.',
        ),
        WordDef(
          'ZONE',
          'Marked area on playing field or court',
          'Scoring from inside the paint zone.',
        ),
        WordDef(
          'POOL',
          'Group of competitors playing in preliminary stage',
          'Finishing top of four-team group pool.',
        ),
        WordDef(
          'TIED',
          'Having equal score in contest with opponent',
          'Match tied two-two going to penalties.',
        ),
        WordDef(
          'LEAD',
          'Position of advantage in score ahead of rivals',
          'Holding a ten-point comfortable lead.',
        ),
        WordDef(
          'PASS',
          'Move ball to teammate during competition',
          'Crisp accurate midfield cross pass.',
        ),
        WordDef(
          'FOUL',
          'Unfair or illegal act in a game violating rules',
          'Whistle blown for defensive foul.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'MEDAL',
          'Metal disc awarded as prize in competition',
          'Olympic gold medal around the neck.',
        ),
        WordDef(
          'TROPHY',
          'Cup or prize awarded to victor in contest',
          'Polished sterling silver trophy cup.',
        ),
        WordDef(
          'FINAL',
          'The last and decisive match in a tournament',
          'Playing in the grand tournament final.',
        ),
        WordDef(
          'LEADER',
          'Person currently ranking highest in standings',
          'Pace setter and tournament leader.',
        ),
        WordDef(
          'PLAYER',
          'Person taking part in game or tournament',
          'Talented seeded tennis match player.',
        ),
        WordDef(
          'REFEREE',
          'Official who watches game to ensure fair play',
          'Referee blowing whistle to start game.',
        ),
        WordDef(
          'VICTORY',
          'Success in game, contest, or battle over rival',
          'Roar of celebration after match victory.',
        ),
        WordDef(
          'RECORD',
          'Best performance achieved in a sport',
          'Setting a new Olympic world record.',
        ),
        WordDef(
          'BRACKET',
          'Diagram showing pairings and progression in tournament',
          'Filling out sixty-four team bracket.',
        ),
        WordDef(
          'PODIUM',
          'Platform on which top three competitors stand',
          'Standing atop the medal podium.',
        ),
        WordDef(
          'RIVALRY',
          'Competition for superiority in same field',
          'Decades-long historic derby rivalry.',
        ),
        WordDef(
          'ATHLETE',
          'Person proficient in sports and exercises',
          'World-class dedicated track athlete.',
        ),
        WordDef(
          'DEFENSE',
          'Action of defending against opponents score',
          'Iron-clad defense denying all shots.',
        ),
        WordDef(
          'OFFENSE',
          'Attacking play designed to score points',
          'Fast-break transition offense.',
        ),
        WordDef(
          'PENALTY',
          'Punishment imposed for breach of the rules',
          'Converting penalty kick into goal.',
        ),
        WordDef(
          'STADIUM',
          'Sports arena with tiers of seats for spectators',
          'Sold-out crowd filling the stadium.',
        ),
        WordDef(
          'QUARTER',
          'One of four periods of play in game',
          'Crucial fourth quarter comeback.',
        ),
        WordDef(
          'PLAYOFF',
          'Game played to decide competition or tie',
          'Intense post-season playoff series.',
        ),
        WordDef(
          'CONTEST',
          'Event in which people compete for supremacy',
          'Three-point shooting skills contest.',
        ),
        WordDef(
          'CAPTAIN',
          'Leader of team on field of play',
          'Team captain tossing the coin.',
        ),
      ],
      longWords: const [
        WordDef(
          'CHAMPION',
          'Person who has surpassed all rivals in contest',
          'Crowned undisputed world champion.',
        ),
        WordDef(
          'TOURNAMENT',
          'Series of contests between multiple teams',
          'Grand slam international tournament.',
        ),
        WordDef(
          'CHAMPIONSHIP',
          'Contest for the position of champion',
          'Winning the premier league championship.',
        ),
        WordDef(
          'COMPETITION',
          'The activity of competing against others',
          'Fierce international athletic competition.',
        ),
        WordDef(
          'SCOREBOARD',
          'Large board displaying score in game',
          'Clock ticking down on the scoreboard.',
        ),
        WordDef(
          'SPORTSMANSHIP',
          'Fair and generous behavior or treatment of others',
          'True sportsmanship shaking hands.',
        ),
        WordDef(
          'SEMIFINAL',
          'Match immediately preceding final in tournament',
          'Advancing through hard-fought semifinal.',
        ),
        WordDef(
          'QUALIFIER',
          'Match played to qualify for a main tournament',
          'Winning the continental cup qualifier.',
        ),
        WordDef(
          'LEADERBOARD',
          'Board displaying names and scores of leaders',
          'Climbing to top spot on leaderboard.',
        ),
        WordDef(
          'SPECTATOR',
          'Person who watches a sports event at venue',
          'Cheering spectators in packed arena.',
        ),
        WordDef(
          'KNOCKOUT',
          'Tournament system where loser is eliminated',
          'Single-elimination knockout stage.',
        ),
        WordDef(
          'PERFORMANCE',
          'An act of staging or presenting sports feats',
          'Record-breaking athletic performance.',
        ),
        WordDef(
          'CONTENDER',
          'Person or team competing with chance of winning',
          'Top title contender in the league.',
        ),
        WordDef(
          'ENDORSEMENT',
          'Sponsorship deal signed by famous athlete',
          'Signing major sports brand endorsement.',
        ),
        WordDef(
          'OVERTIME',
          'Extra period played when scores are tied',
          'Golden goal winner scored in overtime.',
        ),
        WordDef(
          'GRAND SLAM',
          'Winning all major championship tournaments',
          'Achieving the legendary tennis Grand Slam.',
        ),
        WordDef(
          'MEDALIST',
          'Competitor who wins a medal in contest',
          'Olympic gold medalist on the podium.',
        ),
        WordDef(
          'DECATHLON',
          'Athletic event taking place over two days with ten feats',
          'Gold winner of the Olympic decathlon.',
        ),
        WordDef(
          'MARATHON',
          'Long-distance running race of 26.2 miles',
          'Crossing finish line of city marathon.',
        ),
        WordDef(
          'UNDERDOG',
          'Competitor thought to have little chance of winning',
          'Inspiring victory by tournament underdog.',
        ),
      ],
    ),

    // 16. Education
    ChapterDef(
      id: 16,
      key: 'education',
      title: 'Education',
      iconAsset: 'assets/chapter_images/education.png',
      themeColor: 0xFF3F51B5,
      shortWords: const [
        WordDef(
          'BOOK',
          'Work of literature or study bound in covers',
          'Reading textbooks for exam study.',
        ),
        WordDef(
          'READ',
          'Look at and comprehend written text',
          'Learning to read and write fluent.',
        ),
        WordDef(
          'MATH',
          'Study of numbers, quantities, and shapes',
          'Solving mental math arithmetic.',
        ),
        WordDef(
          'QUIZ',
          'Quick test of knowledge taken by students',
          'Friday weekly history pop quiz.',
        ),
        WordDef(
          'DESK',
          'Table used by student in school classroom',
          'Sitting at wooden classroom desk.',
        ),
        WordDef(
          'TEST',
          'Short examination of knowledge or skill',
          'Studying hard for the midterm test.',
        ),
        WordDef(
          'NOTE',
          'Brief record of facts written down to assist memory',
          'Reviewing physics lecture notes.',
        ),
        WordDef(
          'PAGE',
          'One side of a leaf of a textbook',
          'Turning to chapter page twenty.',
        ),
        WordDef(
          'TERM',
          'One of the periods into which academic year is divided',
          'Autumn semester school term.',
        ),
        WordDef(
          'DEAN',
          'Head of a university department or faculty',
          'Meeting with the faculty college dean.',
        ),
        WordDef(
          'STUDY',
          'Devote time and attention to acquiring knowledge',
          'Forming a study group in library.',
        ),
        WordDef(
          'ARTS',
          'Subjects of study concerned with human culture',
          'Majoring in fine arts and music.',
        ),
        WordDef(
          'EXAM',
          'Formal test of students knowledge in subject',
          'Writing final semester calculus exam.',
        ),
        WordDef(
          'TASK',
          'Assignment or piece of academic homework',
          'Completing daily homework tasks.',
        ),
        WordDef(
          'PASS',
          'Be successful in an examination or test',
          'Working hard to pass with honors.',
        ),
        WordDef(
          'FAIL',
          'Be unsuccessful in meeting required standard',
          'Learning from tests where you fail.',
        ),
        WordDef(
          'TUTOR',
          'Private teacher instructing single student',
          'Math tutor helping with algebra.',
        ),
        WordDef(
          'GRADE',
          'Mark indicating student performance quality',
          'Achieving an A grade in biology.',
        ),
        WordDef(
          'RULER',
          'Strip of plastic used for measuring lines',
          'Drawing straight line with ruler.',
        ),
        WordDef(
          'BELL',
          'Chime sounding beginning or end of school period',
          'School bell ringing for recess.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'SCHOOL',
          'Institution for educating children and youth',
          'Historic neighborhood public school.',
        ),
        WordDef(
          'DEGREE',
          'Academic qualification awarded by university',
          'Graduating with bachelor degree.',
        ),
        WordDef(
          'STUDENT',
          'Person who is studying at school or college',
          'Hardworking university honors student.',
        ),
        WordDef(
          'TEACHER',
          'Person who teaches, especially in school',
          'Dedicated elementary school teacher.',
        ),
        WordDef(
          'CAMPUS',
          'Grounds and buildings of a university or college',
          'Walking across historic leafy campus.',
        ),
        WordDef(
          'LESSON',
          'Period of learning or teaching in a subject',
          'Interactive morning science lesson.',
        ),
        WordDef(
          'LIBRARY',
          'Building housing book collections for study',
          'Quiet research university library.',
        ),
        WordDef(
          'PENCIL',
          'Instrument for writing with graphite core',
          'Sharpening yellow number two pencil.',
        ),
        WordDef(
          'ERASER',
          'Piece of rubber used to rub out pencil marks',
          'Erasing sketch marks with soft eraser.',
        ),
        WordDef(
          'REPORT',
          'Evaluation of student progress in school term',
          'Excellent grades on semester report.',
        ),
        WordDef(
          'ALGEBRA',
          'Branch of math using symbols to represent numbers',
          'Solving linear algebra equations.',
        ),
        WordDef(
          'SCIENCE',
          'Study of structure and behavior of physical world',
          'Exciting chemistry laboratory science.',
        ),
        WordDef(
          'HISTORY',
          'Study of past events and human civilizations',
          'World history textbook curriculum.',
        ),
        WordDef(
          'BIOLOGY',
          'Study of living organisms and life processes',
          'Dissecting flowers in biology class.',
        ),
        WordDef(
          'PHYSICS',
          'Branch of science concerning matter and energy',
          'Learning laws of motion in physics.',
        ),
        WordDef(
          'COLLEGE',
          'Educational institution offering higher education',
          'Enrolling in four-year state college.',
        ),
        WordDef(
          'COURSE',
          'Series of lectures or lessons in particular subject',
          'Registering for online web course.',
        ),
        WordDef(
          'HONORS',
          'Academic distinction given to top students',
          'Graduating college with magna honors.',
        ),
        WordDef(
          'SEMINAR',
          'Conference or meeting for discussion or training',
          'Attending graduate economics seminar.',
        ),
        WordDef(
          'DIPLOMA',
          'Certificate awarded by educational institution',
          'Proudly framed high school diploma.',
        ),
      ],
      longWords: const [
        WordDef(
          'UNIVERSITY',
          'High level educational institution granting degrees',
          'Applying to prestigious university.',
        ),
        WordDef(
          'EDUCATION',
          'Process of receiving or giving systematic instruction',
          'Access to quality world education.',
        ),
        WordDef(
          'PROFESSOR',
          'Teacher of the highest rank in a college or university',
          'Distinguished mathematics professor.',
        ),
        WordDef(
          'CLASSROOM',
          'Room in which a class of students is taught',
          'Modern interactive digital classroom.',
        ),
        WordDef(
          'GRADUATION',
          'Receiving an academic degree or diploma',
          'Throwing caps at graduation ceremony.',
        ),
        WordDef(
          'CURRICULUM',
          'Subjects comprising a course of study in school',
          'Standardized national school curriculum.',
        ),
        WordDef(
          'KNOWLEDGE',
          'Facts, information, and skills acquired through study',
          'Pursuit of wisdom and deep knowledge.',
        ),
        WordDef(
          'SCHOLARSHIP',
          'Grant or payment made to support students education',
          'Awarded full academic scholarship.',
        ),
        WordDef(
          'BLACKBOARD',
          'Large dark surface for writing with chalk',
          'Teacher writing formulas on blackboard.',
        ),
        WordDef(
          'ASSIGNMENT',
          'Piece of academic work allocated to student',
          'Submitting research essay assignment.',
        ),
        WordDef(
          'LABORATORY',
          'Room equipped for scientific experiments and research',
          'Equipped chemistry science laboratory.',
        ),
        WordDef(
          'LITERATURE',
          'Written works considered to have artistic value',
          'Reading world classic literature.',
        ),
        WordDef(
          'CERTIFICATE',
          'Official document attesting academic achievement',
          'Receiving completion certificate.',
        ),
        WordDef(
          'ACADEMIC',
          'Relating to education and scholarship in schools',
          'Maintaining high academic standards.',
        ),
        WordDef(
          'GEOMETRY',
          'Branch of math concerned with shapes and space',
          'Proving theorems in Euclidean geometry.',
        ),
        WordDef(
          'DICTIONARY',
          'Reference book explaining words and definitions',
          'Looking up vocabulary in dictionary.',
        ),
        WordDef(
          'EXPERIMENT',
          'Scientific procedure undertaken to make discovery',
          'Conducting electricity experiment.',
        ),
        WordDef(
          'FACULTY',
          'Teaching staff of a university or college',
          'Distinguished members of the faculty.',
        ),
        WordDef(
          'INSTITUTE',
          'Organization having a particular purpose in study',
          'Advanced research technology institute.',
        ),
        WordDef(
          'PRESENTATION',
          'Visual speech showcasing academic research',
          'Defending thesis in final presentation.',
        ),
      ],
    ),

    // 17. Technology
    ChapterDef(
      id: 17,
      key: 'technology',
      title: 'Technology',
      iconAsset: 'assets/chapter_images/technology.png',
      themeColor: 0xFF009688,
      shortWords: const [
        WordDef(
          'TECH',
          'Technology and computing tools collectively',
          'Fast growing modern digital tech.',
        ),
        WordDef(
          'CODE',
          'Program instructions written in programming language',
          'Writing clean efficient source code.',
        ),
        WordDef(
          'DATA',
          'Facts and statistics stored in digital systems',
          'Streaming real-time financial data.',
        ),
        WordDef(
          'BYTE',
          'Unit of memory data consisting of 8 bits',
          'Megabytes and gigabytes of storage.',
        ),
        WordDef(
          'NODE',
          'Point in network where lines or pathways intersect',
          'Distributed cloud computing node.',
        ),
        WordDef(
          'CHIP',
          'Small piece of semiconducting silicon with circuits',
          'Next generation 3-nanometer chip.',
        ),
        WordDef(
          'HOST',
          'Computer that mediates access to network data',
          'Hosting websites on cloud server host.',
        ),
        WordDef(
          'LINK',
          'Connection between hyperlinked documents or networks',
          'Clicking website navigation link.',
        ),
        WordDef(
          'PORT',
          'Slot or connection interface on computer hardware',
          'High speed Thunderbolt data port.',
        ),
        WordDef(
          'DRIVE',
          'Device storing computer files and programs',
          'Blazing fast solid state NVMe drive.',
        ),
        WordDef(
          'SYNC',
          'Coordinate multiple devices to share data identically',
          'Cloud sync across phone and laptop.',
        ),
        WordDef(
          'WIFI',
          'Facility allowing computers to connect wirelessly',
          'Connecting to high speed 6E wifi.',
        ),
        WordDef(
          'RAM',
          'Random access temporary high-speed memory',
          'Equipped with 32 gigabytes of RAM.',
        ),
        WordDef(
          'CPU',
          'Central processor executing software instructions',
          'Multi-threaded desktop computer CPU.',
        ),
        WordDef(
          'GPU',
          'Graphics processor rendering pixels and machine learning',
          'High-end AI workstation GPU.',
        ),
        WordDef(
          'APP',
          'Software application designed for mobile or desktop',
          'Downloading puzzle game mobile app.',
        ),
        WordDef(
          'BOT',
          'Autonomous program operating across internet',
          'Helpful automated customer support bot.',
        ),
        WordDef(
          'WEB',
          'The World Wide Web connected system of sites',
          'Surfing modern responsive open web.',
        ),
        WordDef(
          'LOG',
          'Record of events and transactions in software',
          'Checking server debug error log.',
        ),
        WordDef(
          'KEY',
          'Cryptographic code used to encrypt and decrypt',
          'Storing secret API authorization key.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'ROBOT',
          'Machine capable of carrying out complex actions',
          'Autonomous warehouse sorting robot.',
        ),
        WordDef(
          'SERVER',
          'Computer program or device managing access to resources',
          'High availability web database server.',
        ),
        WordDef(
          'ROUTER',
          'Device forwarding data packets between computer networks',
          'Dual band mesh wireless home router.',
        ),
        WordDef(
          'SYSTEM',
          'Set of connected things or parts forming complex whole',
          'Distributed operating operating system.',
        ),
        WordDef(
          'BACKUP',
          'Copy of computer data made in case original is lost',
          'Automatic daily offsite cloud backup.',
        ),
        WordDef(
          'DIGITAL',
          'Relating to signals expressed as series of digits',
          'Modern digital media transformation.',
        ),
        WordDef(
          'ONLINE',
          'Connected to or available through a computer network',
          'Shopping on secure online website.',
        ),
        WordDef(
          'SEARCH',
          'Look for information across databases or internet',
          'Fast search engine indexing queries.',
        ),
        WordDef(
          'SCREEN',
          'Display surface presenting visual output of computer',
          'Vibrant OLED color touch screen.',
        ),
        WordDef(
          'DEVICE',
          'Thing made or adapted for a particular electronic purpose',
          'Connecting smart IoT home device.',
        ),
        WordDef(
          'CODING',
          'Process of writing computer programs in languages',
          'Learning Python and Flutter coding.',
        ),
        WordDef(
          'DOMAIN',
          'Distinct subset of the Internet with common address',
          'Registering custom website domain.',
        ),
        WordDef(
          'CURSOR',
          'Movable indicator on display screen marking position',
          'Flashing vertical text typing cursor.',
        ),
        WordDef(
          'WIDGET',
          'Element of interaction in graphical user interface',
          'Building modular reusable Flutter widget.',
        ),
        WordDef(
          'BINARY',
          'System of numerical notation that has 2 as its base',
          'Machine code written in binary zeroes.',
        ),
        WordDef(
          'HACKER',
          'Person using computers to gain unauthorized access',
          'Defending networks against rogue hacker.',
        ),
        WordDef(
          'MOBILE',
          'Relating to cellular telephones and handheld tech',
          'Cross-platform mobile application.',
        ),
        WordDef(
          'STREAM',
          'Transmit or receive video and audio in real time',
          'Streaming live 4K gaming video.',
        ),
        WordDef(
          'PYTHON',
          'High-level general-purpose programming language',
          'Data analysis written in Python.',
        ),
        WordDef(
          'CLIENT',
          'Computer hardware or software that accesses service',
          'Frontend mobile application client.',
        ),
      ],
      longWords: const [
        WordDef(
          'ALGORITHM',
          'Step-by-step procedure for solving a mathematical problem',
          'Efficient sorting search algorithm.',
        ),
        WordDef(
          'AUTOMATION',
          'Use of automatic equipment in manufacturing or code',
          'Industrial robotics and automation.',
        ),
        WordDef(
          'CYBERSPACE',
          'Notional environment in which communication takes place',
          'Exploring interconnected cyberspace.',
        ),
        WordDef(
          'DATABASE',
          'Structured set of data held in computer storage',
          'Relational SQL enterprise database.',
        ),
        WordDef(
          'ENCRYPTION',
          'Process of converting information into secret code',
          'End-to-end 256-bit AES encryption.',
        ),
        WordDef(
          'FRAMEWORK',
          'Supporting structure around which software is built',
          'Developing apps with Flutter framework.',
        ),
        WordDef(
          'HARDWARE',
          'Physical components of a computer system',
          'High-performance computing hardware.',
        ),
        WordDef(
          'INTERFACE',
          'Point where two systems meet and interact with user',
          'Clean intuitive user interface design.',
        ),
        WordDef(
          'MICROCHIP',
          'Tiny semiconductor wafer containing electronic circuits',
          'Fabricating advanced silicon microchip.',
        ),
        WordDef(
          'NETWORK',
          'Group of interconnected computers sharing data',
          'High-speed fiber optic data network.',
        ),
        WordDef(
          'PLATFORM',
          'Standard for hardware of a computer system',
          'Cross-device multiplatform gaming.',
        ),
        WordDef(
          'PROCESSOR',
          'Integrated circuit executing computer commands',
          'High-clock-speed multicore processor.',
        ),
        WordDef(
          'SMARTPHONE',
          'Mobile phone that performs functions of computer',
          'Latest flagship Android smartphone.',
        ),
        WordDef(
          'SOFTWARE',
          'Programs and operating information used by computer',
          'Installing open-source office software.',
        ),
        WordDef(
          'VIRTUALITY',
          'State of being artificial simulation of reality',
          'Immersive virtual reality headset.',
        ),
        WordDef(
          'BANDWIDTH',
          'Range of frequencies within band used for data',
          'Unlimited high bandwidth fiber connection.',
        ),
        WordDef(
          'CYBERSECURITY',
          'State of being protected against criminal use of data',
          'Enterprise cloud cybersecurity defenses.',
        ),
        WordDef(
          'MACHINE LEARNING',
          'Use of algorithms allowing computers to learn from data',
          'Training deep neural machine learning.',
        ),
        WordDef(
          'ARTIFICIAL',
          'Made or produced by human beings rather than nature',
          'Pioneering artificial intelligence.',
        ),
        WordDef(
          'QUANTUM',
          'Branch of computing utilizing quantum mechanics bits',
          'Next generation quantum supercomputer.',
        ),
      ],
    ),

    // 18. Birds
    ChapterDef(
      id: 18,
      key: 'birds',
      title: 'Birds',
      iconAsset: 'assets/chapter_images/birds.png',
      themeColor: 0xFF03A9F4,
      shortWords: const [
        WordDef(
          'BIRD',
          'Warm-blooded egg-laying feathered vertebrate',
          'Colorful songbird singing in the tree.',
        ),
        WordDef(
          'WING',
          'Modified forelimb used for flight by birds',
          'Spreading wide wings to soar on air.',
        ),
        WordDef(
          'BEAK',
          'Birds horny projecting jaws; bill',
          'Sharp hooked beak for tearing fish.',
        ),
        WordDef(
          'NEST',
          'Structure built by bird for laying eggs',
          'Twig woven nest high in oak branches.',
        ),
        WordDef(
          'EGGS',
          'Oval bodies laid by female birds containing embryo',
          'Speckled blue robin eggs in nest.',
        ),
        WordDef(
          'CROW',
          'Large perching bird with glossy black plumage',
          'Clever black crow perching on fence.',
        ),
        WordDef(
          'HAWK',
          'Diurnal bird of prey with broad rounded wings',
          'Red-tailed hawk soaring over meadow.',
        ),
        WordDef(
          'DOVE',
          'Pigeon family bird recognized as symbol of peace',
          'Gentle white dove with olive branch.',
        ),
        WordDef(
          'GULL',
          'Long-winged web-footed seabird with grey white feathers',
          'Seagulls circling fishing harbor.',
        ),
        WordDef(
          'SWAN',
          'Large waterbird with a long flexible neck',
          'Graceful white swan gliding on lake.',
        ),
        WordDef(
          'DUCK',
          'Waterbird with webbed feet and short legs',
          'Mallard duck swimming with ducklings.',
        ),
        WordDef(
          'OWL',
          'Nocturnal bird of prey with large eyes and talons',
          'Wise snowy owl hooting in midnight.',
        ),
        WordDef(
          'JAY',
          'Noisy bird of crow family with blue feathers',
          'Blue jay calling from pine branch.',
        ),
        WordDef(
          'WREN',
          'Small short-winged songbird with cocked tail',
          'Tiny energetic brown garden wren.',
        ),
        WordDef(
          'LARK',
          'Small ground-dwelling songbird singing in flight',
          'Meadow lark singing at morning dawn.',
        ),
        WordDef(
          'KITE',
          'Medium to large bird of prey with long wings',
          'Black-shouldered kite hovering in air.',
        ),
        WordDef(
          'TERN',
          'Seabird related to gulls with forked tail',
          'Arctic tern diving into surf for fish.',
        ),
        WordDef(
          'ROOK',
          'European bird of crow family nesting in colonies',
          'Rooks roosting in winter treetops.',
        ),
        WordDef(
          'LOON',
          'Large waterbird of northern waters with eerie call',
          'Common loon calling across misty lake.',
        ),
        WordDef(
          'TEAL',
          'Small freshwater duck with colorful plumage',
          'Green-winged teal dabbling in marsh.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'EAGLE',
          'Large bird of prey with massive hooked bill',
          'Golden eagle soaring over mountain peak.',
        ),
        WordDef(
          'FALCON',
          'Bird of prey with long pointed wings and fast dive',
          'Peregrine falcon diving at high speed.',
        ),
        WordDef(
          'PARROT',
          'Tropical bird with curved beak and brilliant plumage',
          'Colorful macaw parrot talking in canopy.',
        ),
        WordDef(
          'TOUCAN',
          'Tropical American bird with massive colorful beak',
          'Keel-billed toucan eating rainforest fruit.',
        ),
        WordDef(
          'ROBIN',
          'Small songbird with distinctive orange-red breast',
          'American red-breasted robin in spring.',
        ),
        WordDef(
          'PIGEON',
          'Plump bird with small head and cooing call',
          'City street pigeon pecking breadcrumbs.',
        ),
        WordDef(
          'CANARY',
          'Small songbird of finch family kept as pet',
          'Yellow singing caged pet canary.',
        ),
        WordDef(
          'HERON',
          'Long-legged wading bird with long neck',
          'Great blue heron standing in shallows.',
        ),
        WordDef(
          'PELICAN',
          'Large waterbird with throat pouch for catching fish',
          'Brown pelican diving into ocean bay.',
        ),
        WordDef(
          'STORK',
          'Long-legged long-necked wading bird with straight bill',
          'White stork nesting on European roof.',
        ),
        WordDef(
          'PENGUIN',
          'Flightless sea bird of southern hemisphere',
          'Emperor penguin waddling on Antarctic ice.',
        ),
        WordDef(
          'OSTRICH',
          'Largest living flightless bird native to Africa',
          'Fast running wild African ostrich.',
        ),
        WordDef(
          'PEACOCK',
          'Male peafowl with magnificent iridescent tail',
          'Peacock fanning out dazzling tail.',
        ),
        WordDef(
          'SEAGULL',
          'Seabird with white plumage and squawking call',
          'Seagull catching chips on beach boardwalk.',
        ),
        WordDef(
          'FINCH',
          'Seed-eating songbird with conical bill',
          'Goldfinch feeding on thistle seeds.',
        ),
        WordDef(
          'CONDOR',
          'Very large New World vulture with bald head',
          'California condor soaring over canyon.',
        ),
        WordDef(
          'OSPREY',
          'Fish-eating bird of prey with reversible outer toes',
          'Osprey plunging feet first into water.',
        ),
        WordDef(
          'CUCKOO',
          'Bird with characteristic call laying eggs in nests',
          'Cuckoo bird calling from forest grove.',
        ),
        WordDef(
          'MAGPIE',
          'Long-tailed black and white bird of crow family',
          'Curious magpie collecting shiny items.',
        ),
        WordDef(
          'GROUSE',
          'Medium to large game bird with feathered legs',
          'Ruffed grouse drumming in pine woods.',
        ),
      ],
      longWords: const [
        WordDef(
          'HUMMINGBIRD',
          'Tiny nectar-feeding bird with rapidly vibrating wings',
          'Iridescent hummingbird hovering at bloom.',
        ),
        WordDef(
          'WOODPECKER',
          'Bird with strong bill pecking tree bark for insects',
          'Red-headed woodpecker tapping tree.',
        ),
        WordDef(
          'FLAMINGO',
          'Tall wading bird with pink feathers and curved bill',
          'Flock of pink flamingos in lagoon.',
        ),
        WordDef(
          'ALBATROSS',
          'Very large oceanic bird with massive wingspan',
          'Wandering albatross gliding over waves.',
        ),
        WordDef(
          'KINGFISHER',
          'Brightly colored bird with long bill diving for fish',
          'Common blue kingfisher perched on twig.',
        ),
        WordDef(
          'NIGHTINGALE',
          'Small European songbird singing melodiously at night',
          'Sweet liquid song of nightingale.',
        ),
        WordDef(
          'BALD EAGLE',
          'North American eagle with white head feathers',
          'Majestic bald eagle national symbol.',
        ),
        WordDef(
          'FEATHERED',
          'Covered with feathers like a bird',
          'Brightly feathered tropical birds.',
        ),
        WordDef(
          'SANCTUARY',
          'Nature reserve providing safe habitat for birds',
          'Coastal migratory bird sanctuary.',
        ),
        WordDef(
          'MIGRATION',
          'Seasonal movement of animals from one region to another',
          'Annual autumn southward bird migration.',
        ),
        WordDef(
          'PLUMAGE',
          'A birds feathers collectively',
          'Exquisite iridescent male plumage.',
        ),
        WordDef(
          'ORITHOLOGY',
          'The scientific study of birds and their habitats',
          'Field guide to birdwatching ornithology.',
        ),
        WordDef(
          'ROADRUNNER',
          'Fast-running ground cuckoo of American deserts',
          'Greater roadrunner dashing across sand.',
        ),
        WordDef(
          'CORMORANT',
          'Dark sea bird diving underwater for fish',
          'Double-crested cormorant drying wings.',
        ),
        WordDef(
          'COCKATOO',
          'Parrot with prominent erectile crest',
          'Sulphur-crested white Australian cockatoo.',
        ),
        WordDef(
          'PARAKEET',
          'Small parrot with long slender tail',
          'Green budgerigar pet parakeet in cage.',
        ),
        WordDef(
          'MEGACEROS',
          'Ancient extinct giant prehistoric bird or deer',
          'Prehistoric fossil bird specimen.',
        ),
        WordDef(
          'BITTERN',
          'Marsh bird of heron family with booming call',
          'Camouflaged American bittern in reeds.',
        ),
        WordDef(
          'HORNBILL',
          'Tropical bird with large bill topped by casque',
          'Great hornbill flying through forest canopy.',
        ),
        WordDef(
          'PTARMIGAN',
          'Northern grouse with white winter plumage',
          'White ptarmigan camouflaged in snow.',
        ),
      ],
    ),

    // 19. Pets
    ChapterDef(
      id: 19,
      key: 'pets',
      title: 'Pets',
      iconAsset: 'assets/chapter_images/pets.png',
      themeColor: 0xFFFF9800,
      shortWords: const [
        WordDef(
          'DOG',
          'Domesticated carnivorous mammal with barking call',
          'Friendly golden retriever pet dog.',
        ),
        WordDef(
          'CAT',
          'Small domesticated carnivorous mammal with soft fur',
          'Purring calico lap pet cat.',
        ),
        WordDef(
          'PUP',
          'Young dog, puppy',
          'Energetic fluffy golden puppy pup.',
        ),
        WordDef(
          'PAW',
          'Foot of an animal having claws or pads',
          'Soft velvet kitten front paw.',
        ),
        WordDef(
          'TAIL',
          'Hindmost part of animal extending from backbone',
          'Happy dog wagging its bushy tail.',
        ),
        WordDef(
          'FUR',
          'Soft, thick, hairy coat of a mammal',
          'Brushing the cats thick winter fur.',
        ),
        WordDef(
          'BARK',
          'Sharp explosive cry of a dog',
          'Watchdog sounding a protective bark.',
        ),
        WordDef(
          'PURR',
          'Low continuous vibratory sound made by cats',
          'Contented kitten purr when stroked.',
        ),
        WordDef(
          'BOWL',
          'Round deep dish used for holding pet food or water',
          'Stainless steel water food bowl.',
        ),
        WordDef(
          'LEAD',
          'Strap or cord attached to collar for walking dogs',
          'Clip the leash lead onto the collar.',
        ),
        WordDef(
          'BONE',
          'Hard chew toy or treat given to dogs',
          'Dog chewing happily on a beef bone.',
        ),
        WordDef(
          'BALL',
          'Round toy thrown for dogs to fetch',
          'Playing tennis ball fetch at park.',
        ),
        WordDef(
          'BIRD',
          'Feathered pet kept in a cage like canary',
          'Singing pet parakeet in cage.',
        ),
        WordDef(
          'FISH',
          'Aquatic pet kept in glass bowls or aquariums',
          'Goldfish swimming in home tank.',
        ),
        WordDef(
          'PET',
          'Domestic animal kept for companionship',
          'Loving companion family house pet.',
        ),
        WordDef(
          'FEED',
          'Give food to a pet animal at regular times',
          'Time to feed the hungry puppy kibble.',
        ),
        WordDef(
          'WALK',
          'Take a dog outdoors for exercise on leash',
          'Daily morning dog walk around block.',
        ),
        WordDef(
          'BATH',
          'Washing a pet with water and pet shampoo',
          'Giving the dirty golden retriever a bath.',
        ),
        WordDef(
          'TOY',
          'Object given to pets for play and chewing',
          'Squeaky plush toy for puppies.',
        ),
        WordDef(
          'VET',
          'Veterinary doctor treating pets and animals',
          'Taking cat to the vet clinic checkup.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'PUPPY',
          'Young dog in its early developmental stage',
          'Playful energetic golden puppy.',
        ),
        WordDef(
          'KITTEN',
          'Young cat in its early developmental stage',
          'Curious playful little kitten.',
        ),
        WordDef(
          'PARROT',
          'Colorful pet bird capable of mimicking speech',
          'Green talking pet Amazon parrot.',
        ),
        WordDef(
          'RABBIT',
          'Small mammal with long ears and fluffy tail',
          'Pet fluffy dwarf lop-eared rabbit.',
        ),
        WordDef(
          'COLLAR',
          'Band put around neck of pet for identification',
          'Leather collar with engraved ID tag.',
        ),
        WordDef(
          'LEASH',
          'Strap or cord used to restrain and walk dogs',
          'Holding sturdy nylon dog walking leash.',
        ),
        WordDef(
          'CARRIER',
          'Portable box or cage for transporting pets',
          'Putting cat in travel carrier for vet.',
        ),
        WordDef(
          'FERRET',
          'Domesticated polecat kept as an inquisitive pet',
          'Playful pet ferret exploring tunnels.',
        ),
        WordDef(
          'GERBIL',
          'Burrowing rodent with long tail kept as pet',
          'Mongolian gerbil running on wheel.',
        ),
        WordDef(
          'HAMSTER',
          'Small rodent with pouch cheeks and short tail',
          'Syrian golden hamster in cage maze.',
        ),
        WordDef(
          'GUINEA',
          'Guinea pig small tailess pet rodent',
          'Cuddly squeaking pet guinea pig.',
        ),
        WordDef(
          'TURTLE',
          'Slow-moving reptile with bony shell kept in tank',
          'Pet red-eared slider water turtle.',
        ),
        WordDef(
          'LIZARD',
          'Reptilian pet kept in terrariums under heat lamp',
          'Pet bearded dragon terrarium lizard.',
        ),
        WordDef(
          'KENNEL',
          'Shelter for dogs or facility boarding pets',
          'Dog resting in outdoor wooden kennel.',
        ),
        WordDef(
          'GROOMER',
          'Professional who cleans and styles pet fur',
          'Taking poodle to pet salon groomer.',
        ),
        WordDef(
          'TRAINER',
          'Person teaching obedience and tricks to dogs',
          'Certified positive reward dog trainer.',
        ),
        WordDef(
          'MUZZLE',
          'Device placed over mouth of animal to prevent biting',
          'Soft breathable mesh safety muzzle.',
        ),
        WordDef(
          'HARNESS',
          'Set of straps fitted around pet chest for walking',
          'Reflective no-pull dog walking harness.',
        ),
        WordDef(
          'CANINE',
          'Relating to or resembling dogs',
          'Canine agility obstacle course.',
        ),
        WordDef(
          'FELINE',
          'Relating to or affecting cats or the cat family',
          'Graceful feline stretching on sofa.',
        ),
      ],
      longWords: const [
        WordDef(
          'VETERINARIAN',
          'Doctor qualified to treat diseased or injured animals',
          'Caring veterinarian examining puppy.',
        ),
        WordDef(
          'COMPANION',
          'Person or animal with whom one spends much time',
          'Loyal loving animal pet companion.',
        ),
        WordDef(
          'GOLDEN RETRIEVER',
          'Popular breed of intelligent friendly dog',
          'Gentle family pet golden retriever.',
        ),
        WordDef(
          'GERMAN SHEPHERD',
          'Large agile breed of working and guard dog',
          'Intelligent loyal German shepherd.',
        ),
        WordDef(
          'CHIHUAHUA',
          'Very small breed of smooth or long-coated dog',
          'Tiny alert Mexican pet chihuahua.',
        ),
        WordDef(
          'TERRARIUM',
          'Glass enclosure for keeping small land animals',
          'Heated glass reptile terrarium.',
        ),
        WordDef(
          'AQUARIUM',
          'Transparent tank of water for fish and water plants',
          'Colorful tropical fish aquarium tank.',
        ),
        WordDef(
          'OBEDIENCE',
          'Compliance with an order, request, or law for pets',
          'Dog training obedience certificate.',
        ),
        WordDef(
          'MICROCHIP',
          'Electronic chip implanted under pet skin for tracking',
          'Scanning lost pet for microchip ID.',
        ),
        WordDef(
          'DOMESTICATED',
          'Tamed and kept as a pet or on a farm',
          'Generations of domesticated dogs.',
        ),
        WordDef(
          'PLAYFULNESS',
          'Quality of being full of fun and high spirits',
          'Kitten boundless energy and playfulness.',
        ),
        WordDef(
          'VACCINATION',
          'Injection given to protect pets from diseases',
          'Annual canine rabies vaccination.',
        ),
        WordDef(
          'SCRATCHING',
          'Rubbing claws against surface like cat scratching post',
          'Cat sharpening claws on post.',
        ),
        WordDef(
          'LABRADOR',
          'Friendly outgoing water-loving breed of dog',
          'Yellow chocolate and black labrador.',
        ),
        WordDef(
          'MASTIFF',
          'Very large and powerful breed of guard dog',
          'Gentle giant English bull mastiff.',
        ),
        WordDef(
          'BULLDOG',
          'Stocky sturdy breed of dog with wrinkled face',
          'Friendly relaxed English bulldog.',
        ),
        WordDef(
          'POODLE',
          'Intelligent curly-coated dog breed in sizes',
          'Standard groomed apricot poodle.',
        ),
        WordDef(
          'SIAMESE',
          'Slender short-haired breed of cat with blue eyes',
          'Vocal blue-point Siamese pet cat.',
        ),
        WordDef(
          'PERSIAN',
          'Long-haired breed of cat with flat round face',
          'Fluffy white longhaired Persian cat.',
        ),
        WordDef(
          'SHELTER',
          'Establishment providing temporary home for strays',
          'Adopting rescue dog from animal shelter.',
        ),
      ],
    ),

    // 20. Wild Animals
    ChapterDef(
      id: 20,
      key: 'wild-animals',
      title: 'Wild Animals',
      iconAsset: 'assets/chapter_images/wild-animals.png',
      themeColor: 0xFFE65100,
      shortWords: const [
        WordDef(
          'LION',
          'Large tawny-colored cat with tufted tail; king of beasts',
          'Pride of lions resting in African shade.',
        ),
        WordDef(
          'BEAR',
          'Large heavy mammal with thick fur and sharp claws',
          'Grizzly bear catching salmon in river.',
        ),
        WordDef(
          'WOLF',
          'Wild carnivorous mammal of dog family living in packs',
          'Wolf pack howling at full moon.',
        ),
        WordDef(
          'DEER',
          'Hoofed grazing animal with branched antlers',
          'White-tailed deer grazing at forest edge.',
        ),
        WordDef(
          'FOX',
          'Carnivorous mammal of dog family with bushy tail',
          'Clever red fox darting through snow.',
        ),
        WordDef(
          'BOAR',
          'Wild pig with tusks from which domestic pigs descend',
          'Wild boar foraging in European forest.',
        ),
        WordDef(
          'LYNX',
          'Wild cat with yellowish-brown coat and tufted ears',
          'Eurasian lynx prowling through snowy taiga.',
        ),
        WordDef(
          'PUMA',
          'Large wild cat of the Americas; cougar or mountain lion',
          'Puma stalking prey across canyon rocks.',
        ),
        WordDef(
          'APE',
          'Large tailless primate including chimpanzees and gorillas',
          'Mountain gorilla silverback ape.',
        ),
        WordDef(
          'ELK',
          'Large deer with grand palmate antlers',
          'Bull elk bugling in autumn meadows.',
        ),
        WordDef(
          'YAK',
          'Large domesticated wild ox with shaggy hair in Tibet',
          'Himalayan yak grazing on high slopes.',
        ),
        WordDef(
          'HARE',
          'Fast-running mammal resembling large rabbit',
          'Snowshoe hare changing coat to white.',
        ),
        WordDef(
          'MOLE',
          'Small burrowing mammal with dark velvety fur',
          'Underground mole digging tunnels.',
        ),
        WordDef(
          'BAT',
          'Nocturnal flying mammal with webbed wings',
          'Fruit bat flying out of cave at dusk.',
        ),
        WordDef(
          'SEAL',
          'Fish-eating aquatic mammal with flippers',
          'Harbor seal basking on coastal rocks.',
        ),
        WordDef(
          'VOLE',
          'Small rodent resembling short-tailed mouse',
          'Meadow vole darting through tall grass.',
        ),
        WordDef(
          'IBEX',
          'Wild mountain goat with long curved ridged horns',
          'Alpine ibex leaping across steep crags.',
        ),
        WordDef(
          'ORYX',
          'Large African antelope with long straight horns',
          'Scimitar oryx enduring desert heat.',
        ),
        WordDef(
          'GNU',
          'Wildebeest large African antelope with curved horns',
          'Great migration of gnu across river.',
        ),
        WordDef(
          'TOAD',
          'Tailless amphibian with warty skin living on land',
          'Common brown toad in garden leaves.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'TIGER',
          'Large carnivorous feline with orange and black stripes',
          'Bengal tiger stalking through jungle.',
        ),
        WordDef(
          'ZEBRA',
          'African wild horse with black-and-white stripes',
          'Herd of zebras grazing in savannah.',
        ),
        WordDef(
          'MONKEY',
          'Small to medium primate with a tail living in trees',
          'Spider monkey swinging through canopy.',
        ),
        WordDef(
          'PANDA',
          'Large black-and-white bear native to bamboo forests',
          'Giant panda munching fresh bamboo.',
        ),
        WordDef(
          'JAGUAR',
          'Large spotted feline native to Central and South America',
          'Spotted jaguar swimming in Amazon river.',
        ),
        WordDef(
          'LEOPARD',
          'Large solitary cat with rosette-spotted coat',
          'Leopard resting in acacia tree branches.',
        ),
        WordDef(
          'GIRAFFE',
          'Tallest living terrestrial animal with long neck',
          'Giraffe browsing high acacia tree leaves.',
        ),
        WordDef(
          'CHEETAH',
          'Fastest land animal capable of bursts up to 70 mph',
          'Cheetah sprinting across plains.',
        ),
        WordDef(
          'HYENA',
          'Carnivorous scavenger mammal of Africa with powerful jaws',
          'Spotted hyena pack laughing at night.',
        ),
        WordDef(
          'BADGER',
          'Heavy-set burrowing mammal with striped head',
          'Nocturnal European badger outside sett.',
        ),
        WordDef(
          'BEAVER',
          'Semiaquatic rodent known for building dams from trees',
          'Busy beaver building stick river dam.',
        ),
        WordDef(
          'OTTER',
          'Semiaquatic fish-eating mammal with webbed feet',
          'River otter sliding into clear water.',
        ),
        WordDef(
          'WALRUS',
          'Large marine mammal with flippers and long tusks',
          'Arctic walrus herd hauling out on ice.',
        ),
        WordDef(
          'COYOTE',
          'Wild dog native to North America with distinctive howl',
          'Coyote hunting mice in desert prairie.',
        ),
        WordDef(
          'DINGO',
          'Wild dog native to the Australian continent',
          'Australian dingo roaming the outback.',
        ),
        WordDef(
          'BABOON',
          'Large ground-dwelling monkey with doglike muzzle',
          'Troop of baboons on rocky hillsides.',
        ),
        WordDef(
          'GORILLA',
          'Largest living primate native to central Africa',
          'Gentle silverback gorilla in mist.',
        ),
        WordDef(
          'JACKAL',
          'Slender wild dog of Africa and Asia',
          'Golden jackal scavenging on savannah.',
        ),
        WordDef(
          'WOMBAT',
          'Burrowing plant-eating Australian marsupial',
          'Stout common wombat emerging from burrow.',
        ),
        WordDef(
          'OCELOT',
          'Medium-sized wild cat with beautifully spotted coat',
          'Secretive nocturnal ocelot in brush.',
        ),
      ],
      longWords: const [
        WordDef(
          'ELEPHANT',
          'Largest living land mammal with trunk and ivory tusks',
          'African elephant matriarch leading herd.',
        ),
        WordDef(
          'RHINOCEROS',
          'Massive heavy mammal with one or two horns on snout',
          'Black rhinoceros grazing in grasslands.',
        ),
        WordDef(
          'HIPPOPOTAMUS',
          'Large semiaquatic African mammal with huge jaws',
          'Hippopotamus submerged in river pool.',
        ),
        WordDef(
          'KANGAROO',
          'Large Australian herbivore marsupial leaping on hind legs',
          'Red kangaroo bounding across outback.',
        ),
        WordDef(
          'CHIMPANZEE',
          'Intelligent African ape closely related to humans',
          'Chimpanzee using twig tools for termites.',
        ),
        WordDef(
          'ORANGUTAN',
          'Large red-haired arboreal ape of Borneo and Sumatra',
          'Orangutan swinging through rainforest.',
        ),
        WordDef(
          'CROCODILE',
          'Large predatory reptile with armored skin and long jaws',
          'Nile crocodile basking on riverbank.',
        ),
        WordDef(
          'ALLIGATOR',
          'Large reptile related to crocodile with broad rounded snout',
          'American alligator in Florida Everglades.',
        ),
        WordDef(
          'ARMADILLO',
          'Nocturnal mammal with body encased in bony plates',
          'Nine-banded armadillo rooting for bugs.',
        ),
        WordDef(
          'PORCUPINE',
          'Rodent with defensive coat of sharp pointed quills',
          'Crested porcupine rattling warning quills.',
        ),
        WordDef(
          'CHINCHILLA',
          'Small South American rodent with extremely dense soft fur',
          'Mountain chinchilla living in Andes.',
        ),
        WordDef(
          'SALAMANDER',
          'Lizardlike amphibian with moist skin and long tail',
          'Spotted salamander under damp log.',
        ),
        WordDef(
          'CHAMELEON',
          'Lizard known for changing skin color and rotating eyes',
          'Color-changing chameleon on branch.',
        ),
        WordDef(
          'ANTEATER',
          'Mammal with long snout and sticky tongue for eating ants',
          'Giant anteater tearing into termite mound.',
        ),
        WordDef(
          'PLATYPUS',
          'Egg-laying semiaquatic mammal with duck bill and webbed feet',
          'Unique Australian platypus in stream.',
        ),
        WordDef(
          'WOLVERINE',
          'Heavily built solitary carnivorous mammal of northern regions',
          'Fierce wolverine roaming the tundra.',
        ),
        WordDef(
          'WILDERNESS',
          'Natural wild environment unaffected by human activity',
          'Untamed mountain wilderness reserve.',
        ),
        WordDef(
          'CARNIVOROUS',
          'Animal that feeds primarily on flesh and meat',
          'Carnivorous apex predator hunting.',
        ),
        WordDef(
          'HERBIVOROUS',
          'Animal that feeds strictly on plants and vegetation',
          'Herbivorous grazing ungulate herds.',
        ),
        WordDef(
          'PREHISTORIC',
          'Relating to period before written history began',
          'Prehistoric woolly mammoth fossils.',
        ),
      ],
    ),

    // 21. Ocean
    ChapterDef(
      id: 21,
      key: 'ocean',
      title: 'Ocean',
      iconAsset: 'assets/chapter_images/ocean.png',
      themeColor: 0xFF0288D1,
      shortWords: const [
        WordDef(
          'SEAS',
          'Expanses of salt water covering much of the earth',
          'Sailing the seven open turquoise seas.',
        ),
        WordDef(
          'WAVE',
          'Ridge of water moving across surface of ocean',
          'Surfer catching a giant rolling ocean wave.',
        ),
        WordDef(
          'TIDE',
          'Alternate rising and falling of the sea level',
          'High tide flooding the tidal estuary.',
        ),
        WordDef(
          'REEF',
          'Ridge of jagged rock or coral near water surface',
          'Vibrant coral reef teeming with fish.',
        ),
        WordDef(
          'CRAB',
          'Crustacean with broad carapace and pinching claws',
          'Sand crab scuttling sideways on beach.',
        ),
        WordDef(
          'FISH',
          'Limbless cold-blooded vertebrate living in water',
          'School of tropical fish swimming past.',
        ),
        WordDef(
          'CLAM',
          'Marine bivalve mollusk with two hinged shells',
          'Giant clam nestled in coral reef.',
        ),
        WordDef(
          'KELP',
          'Large brown seaweed forming underwater forests',
          'Giant kelp forest swaying in currents.',
        ),
        WordDef(
          'FOAM',
          'Mass of small bubbles formed on ocean waves',
          'White sea foam spraying against rocks.',
        ),
        WordDef(
          'SURF',
          'Mass or line of white foam formed by breaking waves',
          'Listening to crashing ocean beach surf.',
        ),
        WordDef(
          'FINS',
          'Flattened appendages used by fish for swimming',
          'Shark dorsal fin slicing through water.',
        ),
        WordDef(
          'GULL',
          'Long-winged seabird with grey and white feathers',
          'Seagulls circling above fishing boats.',
        ),
        WordDef(
          'SHIP',
          'Large boat for transporting people across oceans',
          'Ocean liner ship crossing the Atlantic.',
        ),
        WordDef(
          'BOAT',
          'Small vessel propelled on water by oars or engine',
          'Sailboat drifting in peaceful lagoon.',
        ),
        WordDef(
          'PIER',
          'Structure leading out from shore into water',
          'Walking along historic wooden ocean pier.',
        ),
        WordDef(
          'MAST',
          'Tall vertical pole supporting sails on ship',
          'Tall wooden mast creaking in the wind.',
        ),
        WordDef(
          'HELM',
          'Tiller or wheel governing the rudder of a ship',
          'Captain standing at the wooden ship helm.',
        ),
        WordDef(
          'DEEP',
          'Extending far down from the top or surface',
          'Diving into mysterious blue deep waters.',
        ),
        WordDef(
          'BLUE',
          'Color of clear sky and the deep open ocean',
          'Endless expanse of deep azure blue sea.',
        ),
        WordDef(
          'SALT',
          'White crystalline substance giving seawater salinity',
          'Taste of ocean salt spray in the air.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'SHARK',
          'Large predatory marine fish with cartilaginous skeleton',
          'Great white shark cruising the depths.',
        ),
        WordDef(
          'WHALE',
          'Very large marine mammal breathing air through blowhole',
          'Humpback whale breaching out of water.',
        ),
        WordDef(
          'CORAL',
          'Hard stony substance secreted by marine polyp colonies',
          'Colorful brain and staghorn coral.',
        ),
        WordDef(
          'TURTLE',
          'Marine reptile with flippers and streamlined shell',
          'Sea turtle gliding over coral reef.',
        ),
        WordDef(
          'SPONGE',
          'Primitive sedentary aquatic invertebrate with porous body',
          'Natural sea sponge anchored to rock.',
        ),
        WordDef(
          'URCHIN',
          'Small spiny globular marine animal',
          'Black sea urchin with sharp spiky needles.',
        ),
        WordDef(
          'SHRIMP',
          'Small free-swimming crustacean with elongated body',
          'Banded coral shrimp cleaning fish.',
        ),
        WordDef(
          'LOBSTER',
          'Large marine crustacean with prominent pinching claws',
          'Maine lobster crawling on ocean bed.',
        ),
        WordDef(
          'ANCHOR',
          'Heavy metal device dropped to moor vessel in water',
          'Dropping heavy iron anchor in the bay.',
        ),
        WordDef(
          'ISLAND',
          'Piece of land surrounded on all sides by water',
          'Lush tropical volcanic ocean island.',
        ),
        WordDef(
          'VOYAGE',
          'Long journey involving travel across the ocean',
          'Historic voyage around Cape Horn.',
        ),
        WordDef(
          'MARINA',
          'Specially designed harbor with moorings for yachts',
          'Luxury yachts docked at coastal marina.',
        ),
        WordDef(
          'DIVING',
          'Sport or activity of swimming underwater with gear',
          'Scuba diving along colorful drop-off.',
        ),
        WordDef(
          'PELICAN',
          'Large waterbird with huge pouch under bill for fish',
          'Brown pelican diving into ocean swell.',
        ),
        WordDef(
          'SAILOR',
          'Person who works as member of crew on ship',
          'Old salty sailor navigating by stars.',
        ),
        WordDef(
          'TRENCH',
          'Long narrow steep-sided depression in ocean floor',
          'Mariana Trench deepest point on earth.',
        ),
        WordDef(
          'ABYSS',
          'A deep or seemingly bottomless chasm in ocean',
          'Creatures living in the midnight abyss.',
        ),
        WordDef(
          'CURRENT',
          'Body of water moving continuously in definite direction',
          'Warm Gulf Stream ocean current.',
        ),
        WordDef(
          'BARNACLE',
          'Marine crustacean that attaches itself permanently to rocks',
          'Sharp barnacles covering pier pilings.',
        ),
        WordDef(
          'PLANKTON',
          'Microscopic organisms drifting in the sea and oceans',
          'Bioluminescent ocean plankton glowing.',
        ),
      ],
      longWords: const [
        WordDef(
          'OCTOPUS',
          'Eight-armed soft-bodied mollusk known for high intelligence',
          'Clever octopus camouflaging against rock.',
        ),
        WordDef(
          'JELLYFISH',
          'Free-swimming marine coelenterate with gelatinous umbrella',
          'Translucent glowing moon jellyfish.',
        ),
        WordDef(
          'SEAHORSE',
          'Small marine fish with horse-like head and prehensile tail',
          'Tiny seahorse clinging to seagrass.',
        ),
        WordDef(
          'SUBMARINE',
          'Warship or vessel designed to operate underwater',
          'Deep-sea research scientific submarine.',
        ),
        WordDef(
          'LIGHTHOUSE',
          'Tower containing beacon light to warn or guide ships',
          'Coastal stone lighthouse shining at night.',
        ),
        WordDef(
          'STARFISH',
          'Marine echinoderm with five or more radiating arms',
          'Bright red starfish on ocean rocks.',
        ),
        WordDef(
          'DOLPHIN',
          'Small gregarious toothed whale with beaklike snout',
          'Playful dolphins riding bow waves of boat.',
        ),
        WordDef(
          'SQUID',
          'Elongated marine cephalopod with ten arms and tentacles',
          'Giant squid dwelling in deep ocean abyss.',
        ),
        WordDef(
          'STINGRAY',
          'Flat marine fish with long whip-like tail bearing spine',
          'Southern stingray gliding over sand flats.',
        ),
        WordDef(
          'ANEMONE',
          'Sedentary marine coelenterate with stinging tentacles',
          'Clownfish hiding in sea anemone tentacles.',
        ),
        WordDef(
          'BARRACUDA',
          'Large predatory marine fish with razor sharp teeth',
          'Great barracuda stalking silver baitfish.',
        ),
        WordDef(
          'SWORDFISH',
          'Large predatory marine fish with long flat pointed bill',
          'Fast swimming open ocean swordfish.',
        ),
        WordDef(
          'MANTA RAY',
          'Very large ray with wing-like pectoral fins feeding on plankton',
          'Giant manta ray performing graceful loops.',
        ),
        WordDef(
          'CRUSTACEAN',
          'Arthropod of group having segmented body and hard shell',
          'Crabs, lobsters, and shrimp crustaceans.',
        ),
        WordDef(
          'SUBMERSIBLE',
          'Small watercraft designed to operate under water',
          'Deep ocean robotic submersible camera.',
        ),
        WordDef(
          'BIOLUMINESCENT',
          'Emitting light produced by biochemical reactions in organisms',
          'Glowing bioluminescent waves at night.',
        ),
        WordDef(
          'HYDROTHERMAL',
          'Relating to hot water vents on the deep sea ocean floor',
          'Hydrothermal vent black smokers.',
        ),
        WordDef(
          'NAUTILUS',
          'Cephalopod mollusk with spiral chambered shell',
          'Chambered nautilus swimming in deep water.',
        ),
        WordDef(
          'BARRIER REEF',
          'Coral reef running parallel to shore separated by lagoon',
          'Great Barrier Reef visible from space.',
        ),
        WordDef(
          'UNDERWATER',
          'Situated, occurring, or used beneath surface of water',
          'Exploring magical underwater coral gardens.',
        ),
      ],
    ),

    // 22. Weather
    ChapterDef(
      id: 22,
      key: 'weather',
      title: 'Weather',
      iconAsset: 'assets/chapter_images/weather.png',
      themeColor: 0xFF00ACC1,
      shortWords: const [
        WordDef(
          'RAIN',
          'Moisture condensed from atmosphere falling in drops',
          'Pattering spring rain on the windowpane.',
        ),
        WordDef(
          'SNOW',
          'Atmospheric water vapor frozen into ice crystals',
          'Fresh white snow falling softly.',
        ),
        WordDef(
          'WIND',
          'Natural movement of air at any velocity',
          'Gusty autumn wind blowing dry leaves.',
        ),
        WordDef(
          'HAIL',
          'Pellets of frozen rain falling in showers',
          'Sudden summer thunderstorm hail storm.',
        ),
        WordDef(
          'FOG',
          'Thick cloud of tiny water droplets suspended near ground',
          'Dense coastal morning fog rolling in.',
        ),
        WordDef(
          'MIST',
          'Cloud of tiny water droplets in atmosphere like thin fog',
          'Misty morning dew over the lake.',
        ),
        WordDef(
          'WARM',
          'Moderate comfortable degree of heat',
          'Warm pleasant sunny afternoon breeze.',
        ),
        WordDef(
          'COLD',
          'Relatively low temperature or lack of heat',
          'Crisp cold winter morning air.',
        ),
        WordDef(
          'COOL',
          'Fairly low temperature, refreshing and pleasant',
          'Cool evening breeze after hot day.',
        ),
        WordDef(
          'HEAT',
          'Quality of being hot or having high temperature',
          'Midday summer heat shimmering on road.',
        ),
        WordDef(
          'GALE',
          'Very strong wind between a breeze and hurricane',
          'Ocean gale rocking ships at sea.',
        ),
        WordDef(
          'GUST',
          'Brief, strong, sudden rush of wind',
          'Sudden gust of wind blowing hats away.',
        ),
        WordDef(
          'DAMP',
          'Slightly wet, moist, or humid weather',
          'Damp forest floor after morning drizzle.',
        ),
        WordDef(
          'DEW',
          'Tiny drops of water condensing on cool night surfaces',
          'Sparkling dew drops on morning grass.',
        ),
        WordDef(
          'ICIC',
          'Hanging spike of ice formed by dripping water freezing',
          'Glistening icicles on house eaves.',
        ),
        WordDef(
          'CALM',
          'Absence of strong wind or storm; peaceful',
          'Calm sea under clear blue sky.',
        ),
        WordDef(
          'FROST',
          'Deposit of small white ice crystals formed on ground',
          'Crisp autumn frost on garden leaves.',
        ),
        WordDef(
          'HAZE',
          'Slight obscurity of air caused by dust, smoke, or heat',
          'Distant mountain ridges lost in haze.',
        ),
        WordDef(
          'AIR',
          'Invisible gaseous substance surrounding the earth',
          'Breathing fresh clean mountain air.',
        ),
        WordDef(
          'SKY',
          'The region of the atmosphere seen from earth',
          'Endless bright blue sunny sky.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'CLOUDS',
          'Visible mass of condensed watery vapor floating in sky',
          'Fluffy white cumulus clouds in sky.',
        ),
        WordDef(
          'STORMS',
          'Violent disturbance of atmosphere with strong winds',
          'Dark thunder storms rolling over hills.',
        ),
        WordDef(
          'BREEZE',
          'Gentle light refreshing wind',
          'Cool ocean breeze on the balcony.',
        ),
        WordDef(
          'SUNNY',
          'Bright with sunlight; direct sunshine',
          'Warm sunny day for outdoor picnic.',
        ),
        WordDef(
          'FREEZE',
          'Turn from liquid into solid ice by cold',
          'Pond water starting to freeze in winter.',
        ),
        WordDef(
          'THAW',
          'Become liquid or soft as result of warming temperature',
          'Spring thaw melting mountain snows.',
        ),
        WordDef(
          'SHOWER',
          'Brief, often heavy fall of rain, hail, or snow',
          'Passing afternoon rain shower.',
        ),
        WordDef(
          'HUMID',
          'Marked by a relatively high level of water vapor',
          'Humid tropical summer afternoon.',
        ),
        WordDef(
          'CHILLY',
          'Unpleasantly cold or noticeably cool',
          'Chilly autumn evening by the bonfire.',
        ),
        WordDef(
          'DENSE',
          'Thick, heavy and closely compacted like fog',
          'Dense blanket of coastal white fog.',
        ),
        WordDef(
          'SUMMER',
          'The warmest season of the year',
          'Sunny summer beach vacations.',
        ),
        WordDef(
          'WINTER',
          'The coldest season of the year with frost',
          'Cozy fireplace during cold winter.',
        ),
        WordDef(
          'AUTUMN',
          'Season between summer and winter with falling leaves',
          'Golden leaves falling in autumn.',
        ),
        WordDef(
          'SPRING',
          'Season between winter and summer when flowers bloom',
          'Spring blossoms blooming on branches.',
        ),
        WordDef(
          'DRIZZLE',
          'Light rain falling in very fine drops',
          'Gentle gray morning drizzle on roof.',
        ),
        WordDef(
          'FLURRY',
          'Sudden short spell of snowfall or wind',
          'Light flurry of winter snowflakes.',
        ),
        WordDef(
          'MONSOON',
          'Seasonal prevailing wind bringing heavy rains',
          'South Asian summer monsoon deluge.',
        ),
        WordDef(
          'TYPHOON',
          'Tropical storm in the region of the western Pacific',
          'Powerful ocean typhoon bringing gales.',
        ),
        WordDef(
          'BLIZZARD',
          'Severe snowstorm with high winds and low visibility',
          'Raging winter blizzard covering roads.',
        ),
        WordDef(
          'TEMPEST',
          'Violent windy storm with rough surging seas',
          'Ship caught in roaring oceanic tempest.',
        ),
      ],
      longWords: const [
        WordDef(
          'LIGHTNING',
          'Naturally occurring electrostatic discharge in storm',
          'Flash of bright lightning in storm.',
        ),
        WordDef(
          'THUNDERSTORM',
          'Storm with thunder, lightning, and typically heavy rain',
          'Dramatic summer thunderstorm rumble.',
        ),
        WordDef(
          'HURRICANE',
          'Tropical storm with violent winds and storm surges',
          'Category four Atlantic ocean hurricane.',
        ),
        WordDef(
          'TORNADO',
          'Violently rotating funnel-shaped column of air',
          'Twister tornado sweeping across plains.',
        ),
        WordDef(
          'TEMPERATURE',
          'Degree or intensity of heat present in substance',
          'Checking daily outdoor temperature.',
        ),
        WordDef(
          'BAROMETER',
          'Scientific instrument measuring atmospheric pressure',
          'Rising needle on antique barometer.',
        ),
        WordDef(
          'PRECIPITATION',
          'Rain, snow, sleet, or hail that falls to ground',
          'Annual average rainfall precipitation.',
        ),
        WordDef(
          'ATMOSPHERE',
          'Envelope of gases surrounding the earth or planet',
          'Sunbeams piercing the atmosphere.',
        ),
        WordDef(
          'METEOROLOGY',
          'The branch of science concerned with the weather',
          'Studying satellite meteorology models.',
        ),
        WordDef(
          'FORECAST',
          'Prediction or estimate of future weather events',
          'Checking seven-day weather forecast.',
        ),
        WordDef(
          'HUMIDITY',
          'The state or quality of being humid; air moisture',
          'Ninety percent relative humidity.',
        ),
        WordDef(
          'RAINBOW',
          'Arch of colors formed in sky by reflection of light',
          'Double rainbow appearing after storm.',
        ),
        WordDef(
          'HEATWAVE',
          'Prolonged period of abnormally hot weather',
          'Staying indoors during summer heatwave.',
        ),
        WordDef(
          'DOWNPOUR',
          'Heavy, sudden, continuous fall of rain',
          'Caught without umbrella in downpour.',
        ),
        WordDef(
          'SNOWFLAKE',
          'Delicate symmetrical crystal of frozen snow',
          'Unique crystalline snowflake pattern.',
        ),
        WordDef(
          'SUNSHINE',
          'Direct sunlight unbroken by clouds',
          'Basking in glorious golden sunshine.',
        ),
        WordDef(
          'OVERCAST',
          'Covered with clouds; dull and gray sky',
          'Gray overcast afternoon without sun.',
        ),
        WordDef(
          'HAILSTONE',
          'Pellet of hail formed in convective thunderclouds',
          'Golf-ball sized icy hailstones.',
        ),
        WordDef(
          'WHIRLWIND',
          'Column of air moving rapidly in a cylindrical vortex',
          'Dust whirlwind spinning across desert.',
        ),
        WordDef(
          'THERMOMETER',
          'Instrument for measuring and indicating temperature',
          'Mercury thermometer reading thirty degrees.',
        ),
      ],
    ),

    // 23. Sports
    ChapterDef(
      id: 23,
      key: 'sports',
      title: 'Sports',
      iconAsset: 'assets/chapter_images/sports.png',
      themeColor: 0xFF4CAF50,
      shortWords: const [
        WordDef(
          'BALL',
          'Solid or hollow spherical object used in games',
          'Kicking soccer ball across grass.',
        ),
        WordDef(
          'GOAL',
          'Structure or area into which players send ball',
          'Scoring a thrilling winning goal.',
        ),
        WordDef(
          'TEAM',
          'Group of players forming one side in competitive sport',
          'Practicing plays with the team.',
        ),
        WordDef(
          'RUN',
          'Move at a speed faster than walk on foot',
          'Running sprint race toward finish line.',
        ),
        WordDef(
          'JUMP',
          'Push oneself off a surface into the air using muscles',
          'Long jump athlete soaring in air.',
        ),
        WordDef(
          'SWIM',
          'Propel oneself through water using limbs',
          'Swimming freestyle in the pool lane.',
        ),
        WordDef(
          'DIVE',
          'Plunge head first into water from board',
          'Graceful backward flip platform dive.',
        ),
        WordDef(
          'RACE',
          'Competition of speed in running or driving',
          'Winning the hundred meter dash race.',
        ),
        WordDef(
          'SURF',
          'Ride on wave toward shore standing on board',
          'Surfing breaking Pacific ocean waves.',
        ),
        WordDef(
          'SKATE',
          'Move or glide on ice or wheeled roller skates',
          'Speed skating around indoor rink.',
        ),
        WordDef(
          'SKI',
          'Travel over snow on pair of long narrow runners',
          'Downhill ski slalom racing on snow.',
        ),
        WordDef(
          'GOLF',
          'Game played on outdoor course with clubs and small ball',
          'Putting golf ball on fourteenth green.',
        ),
        WordDef(
          'PASS',
          'Kick, hit, or throw ball to teammate',
          'Precise passing between midfielders.',
        ),
        WordDef(
          'KICK',
          'Strike forcefully with the foot',
          'Curving penalty kick past goalkeeper.',
        ),
        WordDef(
          'FOUL',
          'Unfair or illegal play violating sports rules',
          'Referee calling a foul on defender.',
        ),
        WordDef(
          'WIN',
          'Be successful or victorious in a contest',
          'Celebrating championship title win.',
        ),
        WordDef(
          'LOSE',
          'Be defeated in a game or contest',
          'Good sportsmanship when teams lose.',
        ),
        WordDef(
          'TIED',
          'Having equal score in sports contest',
          'Game tied going into sudden death.',
        ),
        WordDef(
          'LEAD',
          'State of having higher score than opponent',
          'Holding a comfortable two-goal lead.',
        ),
        WordDef(
          'COACH',
          'Instructor or trainer of an athletic team',
          'Coach drawing strategy on clipboard.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'SOCCER',
          'Game played by two teams of 11 players with round ball',
          'Playing soccer on green grass pitch.',
        ),
        WordDef(
          'TENNIS',
          'Game played with rackets and felt ball over net',
          'Serving ace in championship tennis.',
        ),
        WordDef(
          'BOXING',
          'Sport of fighting with gloved fists in ring',
          'Heavyweight boxing world title bout.',
        ),
        WordDef(
          'RACING',
          'Sport in which competitors race to be fastest',
          'Formula one high speed auto racing.',
        ),
        WordDef(
          'HOCKEY',
          'Game played on ice with sticks and rubber puck',
          'Slap shot goal in winter ice hockey.',
        ),
        WordDef(
          'ROWING',
          'Sport of propelling racing boats with oars',
          'Eight-person synchronized crew rowing.',
        ),
        WordDef(
          'MEDAL',
          'Metal disc awarded to top three athletes in sport',
          'Olympic gold medal winner on podium.',
        ),
        WordDef(
          'TROPHY',
          'Cup or decorative prize awarded for victory',
          'Lifting the world cup winner trophy.',
        ),
        WordDef(
          'PLAYER',
          'Person taking part in sport or game',
          'Star center forward soccer player.',
        ),
        WordDef(
          'LEAGUE',
          'Collection of sports clubs competing together',
          'Premier league soccer tournament.',
        ),
        WordDef(
          'RECORD',
          'Best performance officially recorded in sport',
          'Breaking the world marathon record.',
        ),
        WordDef(
          'SQUASH',
          'Racket sport played in enclosed four-walled court',
          'Fast-paced rallies in game of squash.',
        ),
        WordDef(
          'KARATE',
          'Martial art of Japanese origin using striking moves',
          'Black belt martial artist in karate.',
        ),
        WordDef(
          'JUDO',
          'Sport of unarmed combat using throwing moves',
          'Scoring ippon throw in judo match.',
        ),
        WordDef(
          'RIVALS',
          'Competing teams or athletes with long history',
          'Arch derby sports match rivals.',
        ),
        WordDef(
          'REFEREE',
          'Official supervising game and enforcing rules',
          'Referee blowing whistle for halftime.',
        ),
        WordDef(
          'SPRINT',
          'Run at full speed over a short distance',
          'Sprinting full gas across finish line.',
        ),
        WordDef(
          'DIVING',
          'Sport of performing acrobatics into water',
          'Ten-meter synchronized springboard diving.',
        ),
        WordDef(
          'STADIUM',
          'Large sports arena with spectator grandstands',
          'Sold-out crowd roaring in stadium.',
        ),
        WordDef(
          'HELMET',
          'Protective headgear worn in contact sports',
          'Wearing certified cycling safety helmet.',
        ),
      ],
      longWords: const [
        WordDef(
          'BASKETBALL',
          'Game played by two teams scoring in high hoop',
          'Slam dunk in NBA championship basketball.',
        ),
        WordDef(
          'VOLLEYBALL',
          'Game played by hitting ball back and forth over net',
          'Beach volleyball spike over sand net.',
        ),
        WordDef(
          'BADMINTON',
          'Game played with rackets and feathered shuttlecock',
          'Fast smash in Olympic badminton match.',
        ),
        WordDef(
          'SKATEBOARD',
          'Riding narrow board mounted on four wheels',
          'Performing kickflips on skateboard.',
        ),
        WordDef(
          'SNOWBOARD',
          'Sliding down snow slope standing on wide board',
          'Carving deep powder snow on snowboard.',
        ),
        WordDef(
          'GYMNASTICS',
          'Exercises developing physical agility and balance',
          'Flawless routine on balance beam gymnastics.',
        ),
        WordDef(
          'ATHLETICS',
          'Track and field events testing physical prowess',
          'Olympic stadium track athletics event.',
        ),
        WordDef(
          'CHAMPION',
          'Competitor who has defeated all rivals in contest',
          'Reigning world heavyweight champion.',
        ),
        WordDef(
          'TOURNAMENT',
          'Series of contests between multiple competitors',
          'Grand Slam tennis tournament final.',
        ),
        WordDef(
          'COMPETITION',
          'Event or contest in which people compete for supremacy',
          'World athletic championship competition.',
        ),
        WordDef(
          'SCOREBOARD',
          'Large display board showing score and time remaining',
          'Glancing at the electronic scoreboard.',
        ),
        WordDef(
          'SPORTSMANSHIP',
          'Fair, respectful, and generous behavior in sport',
          'Applauding opponent in sportsmanship.',
        ),
        WordDef(
          'TRIATHLON',
          'Athletic contest combining swimming, cycling, running',
          'Endurance Ironman triathlon race.',
        ),
        WordDef(
          'MARATHON',
          'Long-distance foot race of 26.2 miles distance',
          'Crossing finish line of Boston marathon.',
        ),
        WordDef(
          'DECATHLON',
          'Ten-event track and field athletic competition',
          'Earning title of greatest athlete in decathlon.',
        ),
        WordDef(
          'POLE VAULT',
          'Track and field event using long flexible pole to jump',
          'Clearing six meters in pole vault.',
        ),
        WordDef(
          'HIGH JUMP',
          'Track and field event jumping over horizontal bar',
          'Fosbury flop technique in high jump.',
        ),
        WordDef(
          'WEIGHTLIFTING',
          'Sport of lifting barbells loaded with weight plates',
          'Clean and jerk Olympic weightlifting.',
        ),
        WordDef(
          'TAEKWONDO',
          'Korean martial art characterized by high fast kicks',
          'Olympic sparring match in taekwondo.',
        ),
        WordDef(
          'ARCHERY',
          'Sport or skill of shooting arrows with a bow',
          'Bullseye hit in target field archery.',
        ),
      ],
    ),

    // 24. Vehicles
    ChapterDef(
      id: 24,
      key: 'vehicles',
      title: 'Vehicles',
      iconAsset: 'assets/chapter_images/vehicles.png',
      themeColor: 0xFFF44336,
      shortWords: const [
        WordDef(
          'CAR',
          'Road vehicle powered by an engine with four wheels',
          'Driving modern electric commuter car.',
        ),
        WordDef(
          'BUS',
          'Large motor vehicle carrying passengers by road',
          'City public transit passenger bus.',
        ),
        WordDef(
          'VAN',
          'Medium-sized motor vehicle used for transporting goods',
          'Delivery cargo van parked at curb.',
        ),
        WordDef(
          'CAB',
          'Taxi vehicle for transporting paying passengers',
          'Hailing yellow taxi cab in downtown.',
        ),
        WordDef(
          'JET',
          'High-speed aircraft powered by turbine engines',
          'Commercial twin-engine passenger jet.',
        ),
        WordDef(
          'BOAT',
          'Vessel for traveling on water propelled by oars or engine',
          'Wooden fishing boat in the harbor.',
        ),
        WordDef(
          'SHIP',
          'Large vessel for navigating ocean waterways',
          'Container freight cargo transport ship.',
        ),
        WordDef(
          'CART',
          'Open two or four-wheeled vehicle pulled by horse',
          'Wooden horse-drawn farm supply cart.',
        ),
        WordDef(
          'TRAM',
          'Rail vehicle running on tracks along public urban streets',
          'Historic electric city street tram.',
        ),
        WordDef(
          'TUBE',
          'Underground railway transit system; metro',
          'Commuting on the London tube subway.',
        ),
        WordDef(
          'ROAD',
          'Wide way between places for vehicles to travel',
          'Paved asphalt interstate highway road.',
        ),
        WordDef(
          'TIRE',
          'Rubber ring placed around wheel rim with air',
          'Checking tire pressure before trip.',
        ),
        WordDef(
          'FUEL',
          'Material burned or consumed to produce power',
          'Filling the tank with unleaded fuel.',
        ),
        WordDef(
          'GEAR',
          'Toothed wheel working with others to alter engine speed',
          'Shifting manual transmission to third gear.',
        ),
        WordDef(
          'RAIL',
          'Steel track along which trains run',
          'High-speed passenger bullet train rail.',
        ),
        WordDef(
          'HOOD',
          'Hinged metal cover over the engine of motor vehicle',
          'Popping the car hood to check oil.',
        ),
        WordDef(
          'DOOR',
          'Hinged barrier allowing entry into vehicle',
          'Closing sliding minivan passenger door.',
        ),
        WordDef(
          'WHEEL',
          'Circular object revolving on axle under vehicle',
          'Alloy steering wheel in driver cockpit.',
        ),
        WordDef(
          'SEAT',
          'Furniture designed for driver or passenger to sit',
          'Ergonomic heated leather car seat.',
        ),
        WordDef(
          'ROOF',
          'Upper exterior surface of vehicle body',
          'Panoramic glass moonroof on car roof.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'TRUCK',
          'Large heavy motor vehicle for transporting goods',
          'Eighteen-wheeler freight cargo truck.',
        ),
        WordDef(
          'TRAIN',
          'Series of railway carriages moved by locomotive',
          'High-speed electric passenger train.',
        ),
        WordDef(
          'PLANE',
          'Powered flying vehicle with fixed wings',
          'Boeing passenger airplane flight.',
        ),
        WordDef(
          'SUBWAY',
          'Underground electric railway transit system',
          'Taking downtown express subway line.',
        ),
        WordDef(
          'FERRY',
          'Boat or ship for conveying passengers across water',
          'Island passenger roll-on car ferry.',
        ),
        WordDef(
          'YACHT',
          'Medium-sized sailing or motor vessel used for pleasure',
          'Luxury motor yacht moored in marina.',
        ),
        WordDef(
          'CANOE',
          'Narrow light boat pointed at both ends with paddles',
          'Paddling wooden canoe down stream.',
        ),
        WordDef(
          'KAYAK',
          'Canoe of Eskimo origin with covered deck and double paddle',
          'Sea kayak gliding through fjords.',
        ),
        WordDef(
          'SCOOTER',
          'Light two-wheeled vehicle with low footboard',
          'Electric commuting street scooter.',
        ),
        WordDef(
          'GLIDER',
          'Light aircraft designed to fly without an engine',
          'Thermal soaring unpowered air glider.',
        ),
        WordDef(
          'TRACTOR',
          'Powerful motor vehicle with large rear tires for farming',
          'Farm tractor plowing fertile field.',
        ),
        WordDef(
          'ENGINE',
          'Machine converting power into motion in vehicle',
          'V8 turbo combustion vehicle engine.',
        ),
        WordDef(
          'BRAKES',
          'Device for slowing or stopping moving vehicle',
          'Hydraulic anti-lock disc car brakes.',
        ),
        WordDef(
          'CLUTCH',
          'Mechanism for connecting and disconnecting engine gears',
          'Pressing foot clutch pedal to shift.',
        ),
        WordDef(
          'PEDALS',
          'Foot-operated levers controlling acceleration and brake',
          'Gas and brake vehicle control pedals.',
        ),
        WordDef(
          'MIRROR',
          'Reflective glass panel showing road behind driver',
          'Adjusting rearview side mirror.',
        ),
        WordDef(
          'WIPERS',
          'Rubber blades cleaning rain and dirt from windshield',
          'Windshield wipers clearing storm rain.',
        ),
        WordDef(
          'LIGHTS',
          'Illuminating headlamps on front of vehicle',
          'High-beam LED headlights on dark road.',
        ),
        WordDef(
          'MOTORS',
          'Machines supplying motive power for vehicles',
          'Twin electric powertrain drive motors.',
        ),
        WordDef(
          'TANKER',
          'Ship or heavy truck designed to carry liquids',
          'Fuel supply highway tanker truck.',
        ),
      ],
      longWords: const [
        WordDef(
          'HELICOPTER',
          'Aircraft with horizontal rotating blades capable of hovering',
          'Coast guard rescue helicopter.',
        ),
        WordDef(
          'MOTORCYCLE',
          'Two-wheeled motor vehicle with saddle and handlebars',
          'Riding touring cruiser motorcycle.',
        ),
        WordDef(
          'AUTOMOBILE',
          'Road vehicle powered by internal combustion or electric motor',
          'Vintage classic collector automobile.',
        ),
        WordDef(
          'LOCOMOTIVE',
          'Powered rail vehicle used for pulling trains',
          'Heavy diesel freight rail locomotive.',
        ),
        WordDef(
          'SPACESHIP',
          'Vehicle designed to travel in outer space',
          'Orbital crew exploration spaceship.',
        ),
        WordDef(
          'HOVERCRAFT',
          'Vehicle supported on a cushion of air across land or water',
          'Amphibious coastal rescue hovercraft.',
        ),
        WordDef(
          'AMBULANCE',
          'Vehicle equipped for taking sick people to hospital',
          'Emergency sirens wailing on ambulance.',
        ),
        WordDef(
          'BICYCLE',
          'Vehicle composed of two wheels held in a frame propelled by pedals',
          'Riding lightweight road racing bicycle.',
        ),
        WordDef(
          'SPEEDBOAT',
          'Fast motorboat with powerful inboard or outboard engine',
          'Speedboat racing across blue waters.',
        ),
        WordDef(
          'MONORAIL',
          'Railway system in which track consists of single rail',
          'Futuristic urban airport monorail.',
        ),
        WordDef(
          'TROLLEYBUS',
          'Bus powered by overhead electric wires',
          'Eco-friendly electric city trolleybus.',
        ),
        WordDef(
          'BULLDOZER',
          'Powerful tractor with broad curved blade for clearing earth',
          'Heavy construction site yellow bulldozer.',
        ),
        WordDef(
          'SNOWMOBILE',
          'Motorized vehicle on runners and tracks for snow travel',
          'Snowmobile trail riding through mountains.',
        ),
        WordDef(
          'MINIVAN',
          'Small passenger van designed for family travel',
          'Seven-passenger family vacation minivan.',
        ),
        WordDef(
          'EXCAVATOR',
          'Heavy construction machine with hydraulic arm and bucket',
          'Deep digging construction site excavator.',
        ),
        WordDef(
          'CONVERTIBLE',
          'Car with folding or detachable roof',
          'Driving open-air sports convertible.',
        ),
        WordDef(
          'TRANSMISSION',
          'Mechanism transmitting power from engine to axle',
          'Smooth eight-speed automatic transmission.',
        ),
        WordDef(
          'SPEEDOMETER',
          'Instrument on dashboard indicating vehicle speed',
          'Dashboard digital speedometer dial.',
        ),
        WordDef(
          'WINDSHIELD',
          'Front window of motor vehicle protecting from wind',
          'Laminated glass safety windshield.',
        ),
        WordDef(
          'SPORTS CAR',
          'Low, fast motor car designed for high performance',
          'Italian aerodynamic red sports car.',
        ),
      ],
    ),

    // 25. City
    ChapterDef(
      id: 25,
      key: 'city',
      title: 'City',
      iconAsset: 'assets/chapter_images/city.png',
      themeColor: 0xFF3F51B5,
      shortWords: const [
        WordDef(
          'CITY',
          'Large town or center of population and commerce',
          'Skyscrapers of the modern metropolis city.',
        ),
        WordDef(
          'TOWN',
          'Urban area with a name and defined boundaries',
          'Historic quaint coastal holiday town.',
        ),
        WordDef(
          'PARK',
          'Large public green area in a town for recreation',
          'Strolling through leafy central park.',
        ),
        WordDef(
          'MALL',
          'Large enclosed shopping complex with stores',
          'Browsing stores in shopping mall.',
        ),
        WordDef(
          'SHOP',
          'Building or room where goods or services are sold',
          'Local bakery and coffee shop.',
        ),
        WordDef(
          'BANK',
          'Financial establishment providing monetary services',
          'Depositing savings in commercial bank.',
        ),
        WordDef(
          'ROAD',
          'Wide way between places for vehicle travel',
          'Paved avenue connecting city districts.',
        ),
        WordDef(
          'LANE',
          'Narrow road or marked division of a roadway',
          'Designated green bicycle lane.',
        ),
        WordDef(
          'BUS',
          'Large passenger vehicle traveling city transit routes',
          'Waiting at the downtown bus stop.',
        ),
        WordDef(
          'METRO',
          'Underground or elevated urban railway transit system',
          'Taking the express line on metro.',
        ),
        WordDef(
          'SIGN',
          'Notice bearing information, directions, or warning',
          'Neon street name intersection sign.',
        ),
        WordDef(
          'WALK',
          'Paved path for pedestrians beside a street',
          'Sidewalk pedestrian morning walk.',
        ),
        WordDef(
          'PORT',
          'Harbor where ships dock to load and unload',
          'Bustling container freight sea port.',
        ),
        WordDef(
          'CAFE',
          'Small restaurant selling light meals and drinks',
          'Outdoor sidewalk Parisian style cafe.',
        ),
        WordDef(
          'ZONE',
          'Area of a city subject to particular planning rules',
          'Commercial pedestrian shopping zone.',
        ),
        WordDef(
          'ROOF',
          'Top covering of an urban residential or office building',
          'Rooftop garden overlooking skyline.',
        ),
        WordDef(
          'GRID',
          'Network of streets crossing at right angles',
          'Manhattan street numbered grid plan.',
        ),
        WordDef(
          'SITE',
          'Area of ground on which a town or building is constructed',
          'Active urban building construction site.',
        ),
        WordDef(
          'INN',
          'Establishment providing lodging, food, and drink',
          'Historic cozy downtown travelers inn.',
        ),
        WordDef(
          'CLUB',
          'Association or venue for social or athletic recreation',
          'Attending evening live jazz club.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'STREET',
          'Public road in a city or town with houses or shops',
          'Bustling commercial high street.',
        ),
        WordDef(
          'AVENUE',
          'Broad road in a city, often lined with trees',
          'Fifth Avenue luxury shopping boulevard.',
        ),
        WordDef(
          'SUBWAY',
          'Underground electric railway network in city',
          'Subway train arriving at station platform.',
        ),
        WordDef(
          'BRIDGE',
          'Structure carrying a road or railway across water',
          'Suspension cable steel harbor bridge.',
        ),
        WordDef(
          'TOWER',
          'Tall, narrow building either freestanding or on structure',
          'Observation deck atop city tower.',
        ),
        WordDef(
          'SQUARE',
          'Open typically four-sided area at intersection in town',
          'Gathering in historic town square.',
        ),
        WordDef(
          'PLAZA',
          'Open public space or marketplace in city or town',
          'Fountain in the central civic plaza.',
        ),
        WordDef(
          'CINEMA',
          'Theater where films are shown for public amusement',
          'Watching premiere at movie cinema.',
        ),
        WordDef(
          'HOTEL',
          'Establishment providing accommodation and meals',
          'Five-star luxury downtown hotel suite.',
        ),
        WordDef(
          'CENTER',
          'Point or area that is equally distant from all sides',
          'City center financial district.',
        ),
        WordDef(
          'CORNER',
          'Place where two streets or converging roads meet',
          'Corner store at intersection.',
        ),
        WordDef(
          'MUSEUM',
          'Building where objects of historical interest are kept',
          'Fine art exhibits in city museum.',
        ),
        WordDef(
          'CLINIC',
          'Establishment where outpatients are given medical treatment',
          'Community health and dental clinic.',
        ),
        WordDef(
          'GARAGE',
          'Building or indoor space for parking motor vehicles',
          'Multi-level underground parking garage.',
        ),
        WordDef(
          'TRAIN',
          'Series of connected railway coaches for passengers',
          'Commuter train pulling into terminal.',
        ),
        WordDef(
          'MARKET',
          'Regular gathering of people for purchase and sale of food',
          'Fresh fruit outdoor farmers market.',
        ),
        WordDef(
          'AIRPORT',
          'Complex of runways and buildings for takeoff of aircraft',
          'International hub airport terminal.',
        ),
        WordDef(
          'STATUE',
          'Carved or cast figure of a person or animal',
          'Bronze historical founder monument statue.',
        ),
        WordDef(
          'SUBURB',
          'Outlying residential district of a city',
          'Quiet tree-lined residential suburb.',
        ),
        WordDef(
          'URBAN',
          'Characteristic of a city or populated town',
          'Modern vibrant urban lifestyle.',
        ),
      ],
      longWords: const [
        WordDef(
          'SKYSCRAPER',
          'Very tall building of many stories in a city',
          'Towering glass and steel skyscraper.',
        ),
        WordDef(
          'METROPOLIS',
          'Capital or chief city of a country or region',
          'Bustling glowing night metropolis.',
        ),
        WordDef(
          'BOULEVARD',
          'Wide street in a town or city, typically lined with trees',
          'Sunlight filtering down grand boulevard.',
        ),
        WordDef(
          'PEDESTRIAN',
          'Person walking along a road or in a developed area',
          'Designated pedestrian crossing street.',
        ),
        WordDef(
          'INTERSECTION',
          'Point at which two or more roads intersect',
          'Traffic lights at busy intersection.',
        ),
        WordDef(
          'NEIGHBORHOOD',
          'District or community within a town or city',
          'Friendly historic leafy neighborhood.',
        ),
        WordDef(
          'ARCHITECTURE',
          'The art or practice of designing and constructing buildings',
          'Stunning modern city architecture.',
        ),
        WordDef(
          'CROSSWALK',
          'Marked part of a road where pedestrians have right of way',
          'White zebra stripes painted on crosswalk.',
        ),
        WordDef(
          'RESIDENTIAL',
          'Designed for or providing living accommodations',
          'Peaceful residential apartment quarter.',
        ),
        WordDef(
          'COMMERCIAL',
          'Concerned with commerce and business enterprises',
          'High-density commercial trade zone.',
        ),
        WordDef(
          'TRAFFIC LIGHT',
          'Visual signal device controlling vehicles at road junctions',
          'Waiting for green light at traffic light.',
        ),
        WordDef(
          'APARTMENT',
          'Suite of rooms forming one residence in a building',
          'Modern high-rise balcony apartment.',
        ),
        WordDef(
          'SUPERMARKET',
          'Large self-service grocery store selling foods',
          'Aisles of fresh food in supermarket.',
        ),
        WordDef(
          'PARKING LOT',
          'Area designated for parking motor vehicles',
          'Spacious open paved parking lot.',
        ),
        WordDef(
          'UNDERGROUND',
          'Beneath the surface of the ground; subway railway',
          'Riding underground rapid transit.',
        ),
        WordDef(
          'CIVIC CENTER',
          'Complex of public buildings in a city government',
          'City hall inside modern civic center.',
        ),
        WordDef(
          'COMMUNITY',
          'Group of people living in the same place',
          'Vibrant supportive urban community.',
        ),
        WordDef(
          'POPULATION',
          'All the inhabitants of a particular city or area',
          'Metropolis with eight million population.',
        ),
        WordDef(
          'FIREFIGHTER',
          'Person whose job is to extinguish fires in city',
          'City fire engine and brave firefighter.',
        ),
        WordDef(
          'STREETLIGHT',
          'Light illuminated on pole beside a public street',
          'Glowing amber city streetlight glow.',
        ),
      ],
    ),

    // 26. Home
    ChapterDef(
      id: 26,
      key: 'home',
      title: 'Home',
      iconAsset: 'assets/chapter_images/home.png',
      themeColor: 0xFF8D6E63,
      shortWords: const [
        WordDef(
          'HOME',
          'Place where one lives permanently with family',
          'There is no place like sweet home.',
        ),
        WordDef(
          'ROOM',
          'Space that can be occupied, division inside building',
          'Spacious sunny master bedroom room.',
        ),
        WordDef(
          'DOOR',
          'Hinged, sliding, or revolving barrier at entrance',
          'Opening front door with bronze key.',
        ),
        WordDef(
          'WALL',
          'Continuous vertical brick or stone structure enclosing room',
          'Painting living room wall warm beige.',
        ),
        WordDef(
          'ROOF',
          'Structure forming the upper covering of a building',
          'Shingled water-tight house roof.',
        ),
        WordDef(
          'BED',
          'Piece of furniture for sleep or rest',
          'Comfortable king-size plush mattress bed.',
        ),
        WordDef(
          'SOFA',
          'Long upholstered seat with back and arms for two or more',
          'Relaxing on the living room sofa.',
        ),
        WordDef(
          'LAMP',
          'Device for giving light, consisting of bulb and shade',
          'Warm reading lamp beside armchair.',
        ),
        WordDef(
          'DESK',
          'Piece of furniture with flat top surface for work',
          'Study computer table work desk.',
        ),
        WordDef(
          'RUG',
          'Floor covering of thick woven fabric',
          'Soft wool area rug on hardwood floor.',
        ),
        WordDef(
          'CUP',
          'Small bowl-shaped container for drinking liquids',
          'Hot morning coffee in ceramic cup.',
        ),
        WordDef(
          'FORK',
          'Utensil with two or more prongs used for eating',
          'Silver fork beside dinner plate.',
        ),
        WordDef(
          'PAN',
          'Metal container used for cooking food over heat',
          'Sizzling eggs in cast iron skillet pan.',
        ),
        WordDef(
          'POT',
          'Deep round container used for cooking stews',
          'Simmering soup in stainless steel pot.',
        ),
        WordDef(
          'YARD',
          'Piece of ground adjoining a house; garden or lawn',
          'Children playing in fenced back yard.',
        ),
        WordDef(
          'GATE',
          'Hinged barrier used to close an opening in a fence',
          'Swinging open the wooden garden gate.',
        ),
        WordDef(
          'BATH',
          'Large tub filled with water for washing the body',
          'Relaxing warm bubble bath tub.',
        ),
        WordDef(
          'SINK',
          'Basin with water supply and drain in kitchen or bath',
          'Washing vegetables in kitchen sink.',
        ),
        WordDef(
          'MUG',
          'Large cup, typically cylindrical with handle',
          'Hot cocoa in oversized ceramic mug.',
        ),
        WordDef(
          'OVEN',
          'Enclosed compartment for cooking and baking food',
          'Baking fresh apple pie in the oven.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'HOUSE',
          'Building for human habitation, especially one family',
          'Two-story suburban family house.',
        ),
        WordDef(
          'CHAIR',
          'Separate seat for one person, with back and four legs',
          'Wooden dining room dining chair.',
        ),
        WordDef(
          'TABLE',
          'Piece of furniture with a flat top and legs',
          'Gathering around family dinner table.',
        ),
        WordDef(
          'WINDOW',
          'Opening in wall fitted with glass in a frame',
          'Morning sunlight streaming through window.',
        ),
        WordDef(
          'CLOSET',
          'Small room or cupboard in wall for storing clothes',
          'Hanging jackets in bedroom closet.',
        ),
        WordDef(
          'GARDEN',
          'Piece of ground adjoining house for growing flowers',
          'Watering colorful front flower garden.',
        ),
        WordDef(
          'GARAGE',
          'Building or shed for housing a motor vehicle',
          'Parking car inside two-car garage.',
        ),
        WordDef(
          'PILLOW',
          'Rectangular cloth bag filled with soft material for head',
          'Fluffy down feather sleeping pillow.',
        ),
        WordDef(
          'BLANKET',
          'Large piece of woolen or warm fabric used as bed covering',
          'Wrapping up in a cozy warm blanket.',
        ),
        WordDef(
          'MIRROR',
          'Surface of glass with metal backing reflecting images',
          'Grooming hair in bathroom vanity mirror.',
        ),
        WordDef(
          'KITCHEN',
          'Room where food is prepared and cooked',
          'Cooking gourmet meals in modern kitchen.',
        ),
        WordDef(
          'CARPET',
          'Floor covering made of thick woven fabric',
          'Plush wall-to-wall soft room carpet.',
        ),
        WordDef(
          'DRAWER',
          'Box-shaped storage compartment sliding into furniture',
          'Pulling out wooden dresser drawer.',
        ),
        WordDef(
          'BALCONY',
          'Platform enclosed by a wall on outside of building',
          'Looking out over city from apartment balcony.',
        ),
        WordDef(
          'STAIRS',
          'Set of steps leading from one floor of a building to another',
          'Walking up wooden flight of stairs.',
        ),
        WordDef(
          'CELLAR',
          'Room below ground level in a house used for storage',
          'Storing vintage wine in dark cellar.',
        ),
        WordDef(
          'ATTIC',
          'Space or room just below the roof of a building',
          'Searching old memory boxes in attic.',
        ),
        WordDef(
          'PANTRY',
          'Small room or cupboard in which food and dishes are stored',
          'Stocking dry food supplies in pantry.',
        ),
        WordDef(
          'HEATER',
          'Device for warming the air in a room or house',
          'Electric ceramic radiator space heater.',
        ),
        WordDef(
          'SHOWER',
          'Enclosure where water is sprayed on body to wash',
          'Refreshing hot morning shower stall.',
        ),
      ],
      longWords: const [
        WordDef(
          'FURNITURE',
          'Movable articles that make a room suitable for living',
          'Arranging handcrafted hardwood furniture.',
        ),
        WordDef(
          'APPLIANCE',
          'Device or piece of equipment designed for household task',
          'Kitchen stainless steel home appliance.',
        ),
        WordDef(
          'BEDROOM',
          'Room furnished with a bed and used for sleeping',
          'Cozy peaceful master sleeping bedroom.',
        ),
        WordDef(
          'BATHROOM',
          'Room containing a toilet, sink, and bathtub or shower',
          'Tiled modern master guest bathroom.',
        ),
        WordDef(
          'LIVING ROOM',
          'Room in a house for general and informal everyday use',
          'Family gathering in spacious living room.',
        ),
        WordDef(
          'DINING ROOM',
          'Room in a house in which meals are eaten',
          'Hosting holiday feast in dining room.',
        ),
        WordDef(
          'REFRIGERATOR',
          'Appliance or compartment which is artificially kept cool',
          'Chilling food inside fresh refrigerator.',
        ),
        WordDef(
          'MICROWAVE',
          'Oven that cooks food using electromagnetic radiation',
          'Heating leftovers quickly in microwave.',
        ),
        WordDef(
          'DISHWASHER',
          'Machine for washing dishes and cutlery automatically',
          'Loading plates into quiet dishwasher.',
        ),
        WordDef(
          'FIREPLACE',
          'Place for a domestic fire at base of chimney',
          'Cozy warmth radiating from stone fireplace.',
        ),
        WordDef(
          'DECORATION',
          'The process or art of decorating a room or house',
          'Interior home design and wall decoration.',
        ),
        WordDef(
          'BOOKSHELF',
          'Shelf on which books are organized and kept',
          'Solid oak living room library bookshelf.',
        ),
        WordDef(
          'TELEVISION',
          'Device with screen receiving broadcast programs',
          'Watching evening movies on television.',
        ),
        WordDef(
          'CHANDELIER',
          'Large, decorative hanging light with branches for bulbs',
          'Crystal chandelier sparkling in foyer.',
        ),
        WordDef(
          'CURTAINS',
          'Piece of material suspended at a window to block light',
          'Drawing velvet blackout window curtains.',
        ),
        WordDef(
          'COFFEE TABLE',
          'Low table designed to be placed in front of sofa',
          'Placing art magazines on coffee table.',
        ),
        WordDef(
          'WARDROBE',
          'Large, tall cupboard in which clothes may be hung',
          'Cedar wood hanging clothes wardrobe.',
        ),
        WordDef(
          'THERMOSTAT',
          'Device that automatically regulates room temperature',
          'Setting programmable smart thermostat.',
        ),
        WordDef(
          'VENTILATION',
          'Provision of fresh air to a room or building',
          'Fresh air circulating through ventilation.',
        ),
        WordDef(
          'HOMEWORK',
          'Schoolwork that a pupil is required to do at home',
          'Studying arithmetic homework at table.',
        ),
      ],
    ),

    // 27. Fashion
    ChapterDef(
      id: 27,
      key: 'fashion',
      title: 'Fashion',
      iconAsset: 'assets/chapter_images/fashion.png',
      themeColor: 0xFFE91E63,
      shortWords: const [
        WordDef(
          'HAT',
          'Shaped covering for the head worn for warmth or style',
          'Wide brimmed stylish summer straw hat.',
        ),
        WordDef(
          'CAP',
          'Kind of soft, flat hat, typically with a visor',
          'Embroidered cotton baseball sports cap.',
        ),
        WordDef(
          'BELT',
          'Strip of leather or other material worn around waist',
          'Leather belt with polished metal buckle.',
        ),
        WordDef(
          'RING',
          'Small circular band of precious metal worn on finger',
          'Sparkling diamond engagement gold ring.',
        ),
        WordDef(
          'SILK',
          'Fine, strong, soft, lustrous fiber produced by silkworms',
          'Luxurious smooth draped silk evening scarf.',
        ),
        WordDef(
          'WOOL',
          'Fine, soft curly hair forming fleece of sheep',
          'Warm knitted merino sheep wool sweater.',
        ),
        WordDef(
          'HEEL',
          'Raised component under the back of a shoe',
          'Classic black leather high heel pumps.',
        ),
        WordDef(
          'VEST',
          'Sleeveless garment worn on upper body over shirt',
          'Tailored three-piece suit formal vest.',
        ),
        WordDef(
          'TIE',
          'Strip of material worn around the collar tied in knot',
          'Silk patterned necktie worn with suit.',
        ),
        WordDef(
          'GOWN',
          'Long, elegant dress worn on formal occasions',
          'Floor-length satin red evening ball gown.',
        ),
        WordDef(
          'JEAN',
          'Heavy twill cotton cloth; trousers made of denim',
          'Classic blue denim indigo jeans.',
        ),
        WordDef(
          'BOOT',
          'Sturdy item of footwear covering the foot and ankle',
          'Leather lace-up winter hiking boots.',
        ),
        WordDef(
          'SHOE',
          'Covering for the foot, typically made of leather',
          'Comfortable running and walking shoes.',
        ),
        WordDef(
          'COAT',
          'Outer garment with sleeves worn outdoors for warmth',
          'Heavy wool winter overcoat jacket.',
        ),
        WordDef(
          'LOOK',
          'Particular appearance, style, or fashion aesthetic',
          'Chic minimalist runway fashion look.',
        ),
        WordDef(
          'MODE',
          'Fashion or style in clothes, art, or manners',
          'Living in the height of modern mode.',
        ),
        WordDef(
          'LACE',
          'Fine openwork fabric made by looping or twisting threads',
          'Delicate vintage floral lace trim.',
        ),
        WordDef(
          'BOW',
          'Knot tied with two loops and two loose ends',
          'Tying a crisp black satin tuxedo bow.',
        ),
        WordDef(
          'FIT',
          'The way that a garment sits and contours the body',
          'Custom tailored suit with perfect fit.',
        ),
        WordDef(
          'ZIP',
          'Fastener consisting of two flexible strips of metal teeth',
          'Zipping up the leather motorcycle jacket.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'DRESS',
          'One-piece garment for a woman consisting of skirt and bodice',
          'Floral print summer sundress.',
        ),
        WordDef(
          'SHIRT',
          'Garment for upper body with collar and buttons',
          'Crisp white cotton button-down shirt.',
        ),
        WordDef(
          'PANTS',
          'Trousers; garment covering the body from waist down',
          'Pleated tailored wool dress pants.',
        ),
        WordDef(
          'SKIRT',
          'Garment fastened around waist and hanging down around legs',
          'A-line pleated high-waisted skirt.',
        ),
        WordDef(
          'SUIT',
          'Set of clothes made from same fabric, jacket and trousers',
          'Bespoke navy blue Italian wool suit.',
        ),
        WordDef(
          'JACKET',
          'Outer garment extending to the waist or hips with sleeves',
          'Classic brown leather bomber jacket.',
        ),
        WordDef(
          'TREND',
          'General direction in which fashion is developing',
          'Following the latest spring runway trend.',
        ),
        WordDef(
          'MODEL',
          'Person employed to display clothes in fashion shows',
          'Runway fashion model walking catwalk.',
        ),
        WordDef(
          'STYLE',
          'Distinctive appearance, manner, or design in clothing',
          'Personal sophisticated elegant style.',
        ),
        WordDef(
          'FABRIC',
          'Cloth or other material produced by weaving or knitting',
          'Breathable organic cotton woven fabric.',
        ),
        WordDef(
          'COTTON',
          'Soft white fibrous substance surrounding seeds of plants',
          'One hundred percent natural soft cotton.',
        ),
        WordDef(
          'LEATHER',
          'Material made from skin of an animal by tanning',
          'Supple genuine full-grain leather bag.',
        ),
        WordDef(
          'VELVET',
          'Closely woven fabric of silk or cotton with dense pile',
          'Plush midnight blue velvet tuxedo blazer.',
        ),
        WordDef(
          'DENIM',
          'Sturdy cotton twill fabric, typically blue',
          'Vintage washed durable denim jacket.',
        ),
        WordDef(
          'HOODIE',
          'Sweatshirt with a hood and front kangaroo pocket',
          'Comfortable oversized fleece hoodie.',
        ),
        WordDef(
          'SCARF',
          'Length of fabric worn around neck for warmth or style',
          'Cashmere patterned winter neck scarf.',
        ),
        WordDef(
          'GLOVES',
          'Covering for hand with separate parts for each finger',
          'Lined leather winter dress gloves.',
        ),
        WordDef(
          'DESIGN',
          'Creation of plan or convention for construction of garments',
          'Haute couture fashion design collection.',
        ),
        WordDef(
          'BRAND',
          'Type of product made by a particular company under name',
          'Iconic luxury global fashion brand.',
        ),
        WordDef(
          'SEWING',
          'Craft of stitching fabric together with needle and thread',
          'Precision tailoring and custom sewing.',
        ),
      ],
      longWords: const [
        WordDef(
          'ACCESSORIES',
          'Things that can be added to an outfit to make it more useful',
          'Matching designer leather accessories.',
        ),
        WordDef(
          'SUNGLASSES',
          'Glasses with tinted lenses to protect eyes from sunlight',
          'Polarized aviator style sunglasses.',
        ),
        WordDef(
          'JEWELRY',
          'Personal ornaments such as necklaces, rings, or bracelets',
          'Handcrafted gemstone fine jewelry.',
        ),
        WordDef(
          'NECKLACE',
          'Ornamental chain or string of beads worn around neck',
          'Sparkling diamond pendant necklace.',
        ),
        WordDef(
          'BRACELET',
          'Ornamental band or chain worn on the wrist or arm',
          'Polished sterling silver bangle bracelet.',
        ),
        WordDef(
          'CARDIGAN',
          'Knitted sweater fastening down the front with buttons',
          'Cozy oversized wool knit cardigan.',
        ),
        WordDef(
          'SWEATER',
          'Knitted garment worn on upper body for warmth',
          'Chunky cable-knit cream winter sweater.',
        ),
        WordDef(
          'WARDROBE',
          'The collection of clothes and accessories owned by person',
          'Building a versatile capsule wardrobe.',
        ),
        WordDef(
          'ELEGANCE',
          'The quality of being graceful and stylish in appearance',
          'Classic timeless understated elegance.',
        ),
        WordDef(
          'BOUTIQUE',
          'Small shop selling fashionable clothes or accessories',
          'Shopping at upscale downtown boutique.',
        ),
        WordDef(
          'COLLECTION',
          'Series of garments produced for particular season',
          'Spring and summer designer collection.',
        ),
        WordDef(
          'HANDBAG',
          'Bag used by women to hold personal items like wallet',
          'Luxury quilted leather shoulder handbag.',
        ),
        WordDef(
          'TUXEDO',
          'Mans formal dinner jacket, typically black with satin lapels',
          'Dressing in black tie formal tuxedo.',
        ),
        WordDef(
          'MANNEQUIN',
          'Dummy used to display clothes in a shop window',
          'Dressing window display mannequin.',
        ),
        WordDef(
          'HAUTE COUTURE',
          'High-end fashion that is constructed by hand from start',
          'Paris runway haute couture gown.',
        ),
        WordDef(
          'OVERALLS',
          'Garment consisting of trousers with bib held by straps',
          'Denim carpenter workwear overalls.',
        ),
        WordDef(
          'FOOTWEAR',
          'Outer coverings for the feet, such as shoes or boots',
          'Comfortable supportive athletic footwear.',
        ),
        WordDef(
          'HEADBAND',
          'Band of fabric worn around head to keep hair off face',
          'Velvet padded fashion hair headband.',
        ),
        WordDef(
          'SUSPENDERS',
          'Pair of straps passing over shoulders to hold up trousers',
          'Vintage button-on elastic suspenders.',
        ),
        WordDef(
          'PATTERN',
          'Repeated decorative design on clothing fabric',
          'Houndstooth and tartan woven pattern.',
        ),
      ],
    ),

    // 28. Entertainment
    ChapterDef(
      id: 28,
      key: 'entertainment',
      title: 'Entertainment',
      iconAsset: 'assets/chapter_images/entertainment.png',
      themeColor: 0xFFFF5722,
      shortWords: const [
        WordDef(
          'SHOW',
          'Spectacle or display of performing arts or drama',
          'Watching a live evening Broadway show.',
        ),
        WordDef(
          'FILM',
          'Movie or motion picture projected on a cinema screen',
          'Critically acclaimed indie festival film.',
        ),
        WordDef(
          'PLAY',
          'Dramatic work for stage, television, or radio',
          'Attending Shakespeares classic stage play.',
        ),
        WordDef(
          'CAST',
          'Actors taking part in a play, film, or show',
          'All-star ensemble theatrical film cast.',
        ),
        WordDef(
          'STAR',
          'Famous actor, singer, or performer in entertainment',
          'Hollywood Walk of Fame movie star.',
        ),
        WordDef(
          'SONG',
          'Musical composition with words sung by vocalists',
          'Topping the music charts with hit song.',
        ),
        WordDef(
          'DRUM',
          'Percussion instrument keeping the beat in musical sets',
          'Rhythmic drum beat driving the concert.',
        ),
        WordDef(
          'BAND',
          'Group of musicians playing popular music together',
          'Rock band performing on festival stage.',
        ),
        WordDef(
          'STAGE',
          'Raised floor on which actors and musicians perform',
          'Spotlights illuminating the concert stage.',
        ),
        WordDef(
          'FAME',
          'State of being known or talked about by many people',
          'Achieving worldwide celebrity fame.',
        ),
        WordDef(
          'TAPE',
          'Magnetic strip used for recording video or audio',
          'Archival vintage analog video tape.',
        ),
        WordDef(
          'DISC',
          'Flat, thin, circular object storing digital movies',
          'Playing 4K Blu-ray movie disc.',
        ),
        WordDef(
          'BEAT',
          'Regular pulse or rhythmic unit in musical pieces',
          'Dancing to the energetic electronic beat.',
        ),
        WordDef(
          'TUNE',
          'Melodic musical phrase that is catchy and memorable',
          'Humming the catchy radio theme tune.',
        ),
        WordDef(
          'HERO',
          'Main character admired for courage in movie',
          'Superhero saving the city in blockbuster.',
        ),
        WordDef(
          'FANS',
          'Enthusiastic devotees and followers of an artist',
          'Cheering fans chanting in the arena.',
        ),
        WordDef(
          'ACT',
          'Main division of a play or opera, performance piece',
          'Opening with a dramatic first act.',
        ),
        WordDef(
          'ROLE',
          'Actor portrayal of a character in production',
          'Auditioning for the lead drama role.',
        ),
        WordDef(
          'CREW',
          'Group of people who work on a film or stage set',
          'Cinematographers and film camera crew.',
        ),
        WordDef(
          'PLOT',
          'The main sequence of events in a film or story',
          'Gripping plot with unexpected twists.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'CINEMA',
          'Theater where films are shown for public entertainment',
          'Buying popcorn at the cinema lobby.',
        ),
        WordDef(
          'ACTOR',
          'Person whose profession is acting on stage or screen',
          'Academy Award winning lead actor.',
        ),
        WordDef(
          'DANCER',
          'Person who dances professionally or for recreation',
          'Graceful classical ballet lead dancer.',
        ),
        WordDef(
          'SINGER',
          'Person who sings, especially professionally',
          'Soulful vocalist and acoustic singer.',
        ),
        WordDef(
          'COMEDY',
          'Professional entertainment consisting of jokes and sketches',
          'Stand-up comedy show bringing laughter.',
        ),
        WordDef(
          'DRAMA',
          'Play for theater, radio, or television; genre of emotion',
          'Intense riveting historical courtroom drama.',
        ),
        WordDef(
          'CIRCUS',
          'Traveling company of acrobats, clowns, and performers',
          'Three-ring big top circus performance.',
        ),
        WordDef(
          'TICKETS',
          'Piece of paper giving holder right to enter venue',
          'Reserved front row concert tickets.',
        ),
        WordDef(
          'STUDIO',
          'Room where musical or movie recordings are made',
          'Soundproof Hollywood movie studio.',
        ),
        WordDef(
          'CAMERA',
          'Apparatus for capturing photographs or moving images',
          'Panavision cinematic camera rig.',
        ),
        WordDef(
          'SCREEN',
          'Flat surface on which a picture or movie is projected',
          'Massive IMAX widescreen cinema screen.',
        ),
        WordDef(
          'SEASON',
          'Set of episodes of television series broadcast together',
          'Binge-watching the new television season.',
        ),
        WordDef(
          'SERIES',
          'Set of related television programs with shared characters',
          'Streaming hit sci-fi drama series.',
        ),
        WordDef(
          'STREAM',
          'Transmit audio or video data continuously over internet',
          'Stream latest blockbuster movies in 4K.',
        ),
        WordDef(
          'DIRECT',
          'Control the operations and artistic vision of a film',
          'Directing award-winning feature films.',
        ),
        WordDef(
          'AUTHOR',
          'Writer of books, screenplays, or creative works',
          'Original story author on movie set.',
        ),
        WordDef(
          'RATING',
          'Classification given to a film or show regarding viewers',
          'Rated PG-13 for action adventure.',
        ),
        WordDef(
          'SCENE',
          'Sequence of continuous action in a play or movie',
          'Filming the climactic chase scene.',
        ),
        WordDef(
          'TALENT',
          'Natural aptitude or skill in performance arts',
          'Discovered on stage for raw talent.',
        ),
        WordDef(
          'CHORUS',
          'Large organized group of singers; refrain of song',
          'Singing along with the catchy chorus.',
        ),
      ],
      longWords: const [
        WordDef(
          'PERFORMANCE',
          'An act of staging or presenting a play, concert, or show',
          'Captivating live theatrical performance.',
        ),
        WordDef(
          'CELEBRITY',
          'A famous person, especially in entertainment or sport',
          'Hollywood red carpet celebrity arrivals.',
        ),
        WordDef(
          'PRODUCTION',
          'Process of organizing and filming a movie or show',
          'High-budget studio movie production.',
        ),
        WordDef(
          'TELEVISION',
          'System for transmitting visual images with sound on screens',
          'Broadcasting live across television.',
        ),
        WordDef(
          'SOUNDTRACK',
          'The music accompanying a film or television show',
          'Grammy winning original movie soundtrack.',
        ),
        WordDef(
          'DOCUMENTARY',
          'Movie or television program presenting factual records',
          'Nature wildlife documentary series.',
        ),
        WordDef(
          'AUDIENCE',
          'The assembled spectators or listeners at a public event',
          'Standing ovation from delighted audience.',
        ),
        WordDef(
          'DIRECTOR',
          'Person who supervises actors and crew in a film',
          'Visionary film director framing shots.',
        ),
        WordDef(
          'ENTERTAINMENT',
          'Action of providing or being provided with amusement',
          'World-class musical entertainment.',
        ),
        WordDef(
          'ORCHESTRA',
          'Large group of musicians playing classical instruments',
          'Live orchestra accompanying silent movie.',
        ),
        WordDef(
          'ANIMATION',
          'Technique of filming drawings or models to create motion',
          'Feature 3D computer animation film.',
        ),
        WordDef(
          'BROADCAST',
          'Transmit a program on radio or television',
          'Live global satellite sports broadcast.',
        ),
        WordDef(
          'BLOCKBUSTER',
          'Thing of great power, in particular a very successful film',
          'Summer superhero cinematic blockbuster.',
        ),
        WordDef(
          'RED CARPET',
          'Traditional red carpet rolled out for VIPs and stars',
          'Glamorous film premiere red carpet walk.',
        ),
        WordDef(
          'SPECIAL EFFECTS',
          'Illusions or visual tricks used in film and television',
          'Mind-blowing digital CGI special effects.',
        ),
        WordDef(
          'SCREENPLAY',
          'Script of a film, including acting instructions and scene sets',
          'Writing an original dramatic screenplay.',
        ),
        WordDef(
          'HEADPHONES',
          'Pair of small earphones worn over head for listening',
          'Audio engineer monitoring headphones.',
        ),
        WordDef(
          'MICHAELANGELO',
          'Legendary Renaissance artist of Sistine Chapel ceiling',
          'Masterpieces of Renaissance artistry.',
        ),
        WordDef(
          'HOLLYWOOD',
          'District in Los Angeles associated with American film',
          'Heart of global movie making in Hollywood.',
        ),
        WordDef(
          'INTERMISSION',
          'A pause or break between parts of a play or concert',
          'Buying refreshments during intermission.',
        ),
      ],
    ),

    // 29. Adventure
    ChapterDef(
      id: 29,
      key: 'adventure',
      title: 'Adventure',
      iconAsset: 'assets/chapter_images/adventure.png',
      themeColor: 0xFFFF9800,
      shortWords: const [
        WordDef(
          'TREK',
          'Long arduous journey, typically on foot across terrain',
          'Challenging high altitude mountain trek.',
        ),
        WordDef(
          'CAMP',
          'Place with temporary accommodation of tents or huts',
          'Setting up wilderness base camp.',
        ),
        WordDef(
          'MAP',
          'Diagrammatic representation of an area of land or sea',
          'Following topographical navigation map.',
        ),
        WordDef(
          'HIKE',
          'Walk a long distance, especially across country',
          'Hiking rugged alpine trail passes.',
        ),
        WordDef(
          'PEAK',
          'Pointed top of a mountain or mountain ridge',
          'Reaching the snowy mountain summit peak.',
        ),
        WordDef(
          'PATH',
          'Way or track laid down for walking or made by footsteps',
          'Narrow winding path through the woods.',
        ),
        WordDef(
          'CAVE',
          'Natural underground chamber in hillside or cliff',
          'Exploring hidden subterranean cave.',
        ),
        WordDef(
          'ROPE',
          'Length of thick strong cord made by twisting strands',
          'Climbing steep rock face with nylon rope.',
        ),
        WordDef(
          'RAFT',
          'Flat buoyant structure of timber or inflatable rubber',
          'White water rafting down roaring river.',
        ),
        WordDef(
          'WILD',
          'In a state of nature; not domesticated or cultivated',
          'Exploring untouched untamed wild lands.',
        ),
        WordDef(
          'HERO',
          'Person admired for courage, outstanding achievements',
          'Brave hero facing unknown perils.',
        ),
        WordDef(
          'DIVE',
          'Plunge into water to explore underwater reefs',
          'Scuba diving sunken shipwreck ruins.',
        ),
        WordDef(
          'SAIL',
          'Travel in a boat with sails across open waters',
          'Sailing across the southern ocean.',
        ),
        WordDef(
          'SURF',
          'Ride breaking ocean waves toward shore on board',
          'Big wave surfing off remote islands.',
        ),
        WordDef(
          'PACK',
          'Bag carried on back containing travel gear; backpack',
          'Strapping on 60-liter travel pack.',
        ),
        WordDef(
          'TENT',
          'Portable shelter made of cloth supported by poles',
          'Weatherproof dome tent in gale.',
        ),
        WordDef(
          'GOLD',
          'Precious yellow metal sought in treasure quests',
          'Searching for sunken galleon gold.',
        ),
        WordDef(
          'ISLE',
          'An island or small piece of land surrounded by water',
          'Remote windswept Scottish isle.',
        ),
        WordDef(
          'CAPE',
          'Headland or promontory of large size extending into water',
          'Rounding the stormy Cape of Good Hope.',
        ),
        WordDef(
          'BAY',
          'Broad inlet of the sea where the land curves inward',
          'Dropping anchor in secluded island bay.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'JOURNEY',
          'Act of traveling from one place to another',
          'Embarking on a thrilling epic journey.',
        ),
        WordDef(
          'SAFARI',
          'Expedition to observe or hunt animals in wild',
          'African wildlife open vehicle safari.',
        ),
        WordDef(
          'ISLAND',
          'Piece of land surrounded on all sides by water',
          'Uninhabited tropical desert island.',
        ),
        WordDef(
          'JUNGLE',
          'Area of land overgrown with dense forest and vegetation',
          'Hacking path through Amazonian jungle.',
        ),
        WordDef(
          'VOYAGE',
          'Long journey involving travel by sea or in space',
          'Transatlantic sailing ship voyage.',
        ),
        WordDef(
          'DESERT',
          'Barren area of land where little precipitation occurs',
          'Crossing the vast Sahara sand desert.',
        ),
        WordDef(
          'CANYON',
          'Deep gorge, typically one with a river flowing through',
          'Hiking along the floor of red rock canyon.',
        ),
        WordDef(
          'COMPASS',
          'Instrument containing magnetized pointer showing direction',
          'Navigating true north with magnetic compass.',
        ),
        WordDef(
          'SUMMIT',
          'The highest point of a hill or mountain',
          'Standing triumphantly atop Everest summit.',
        ),
        WordDef(
          'VALLEY',
          'Low area of land between hills or mountains',
          'Glacial valley carved between peaks.',
        ),
        WordDef(
          'GLACIER',
          'Slowly moving mass or river of ice formed on mountains',
          'Traversing crevasse fields on glacier.',
        ),
        WordDef(
          'FOREST',
          'Large area covered chiefly with trees and undergrowth',
          'Trekking through old-growth rain forest.',
        ),
        WordDef(
          'RIVER',
          'Large natural stream of water flowing in channel to sea',
          'Navigating turbulent white water river.',
        ),
        WordDef(
          'EXPLORE',
          'Travel in or through unfamiliar area in order to learn',
          'Eager to explore uncharted territories.',
        ),
        WordDef(
          'DANGER',
          'Possibility of suffering harm or injury in wilderness',
          'Braving extreme mountain danger.',
        ),
        WordDef(
          'COURAGE',
          'Ability to do something that frightens one; bravery',
          'Displaying remarkable grit and courage.',
        ),
        WordDef(
          'SURVIVE',
          'Continue to live or exist in spite of hardship or danger',
          'Skill in how to survive in wild.',
        ),
        WordDef(
          'HORIZON',
          'Line at which the earth surface and sky appear to meet',
          'Chasing the distant golden sunset horizon.',
        ),
        WordDef(
          'ANCHOR',
          'Heavy metal device used to moor a ship to sea bottom',
          'Dropping anchor in uncharted bay.',
        ),
        WordDef(
          'STORM',
          'Violent disturbance of atmosphere with strong winds',
          'Navigating through raging ocean storm.',
        ),
      ],
      longWords: const [
        WordDef(
          'EXPEDITION',
          'Journey undertaken by group of people with purpose',
          'Scientific polar ice cap expedition.',
        ),
        WordDef(
          'DISCOVERY',
          'The act or process of discovering something unknown',
          'Making an astonishing archaeological discovery.',
        ),
        WordDef(
          'WILDERNESS',
          'Ungridded, uninhabited, and uncultivated region',
          'Solitude in pristine Alaskan wilderness.',
        ),
        WordDef(
          'NAVIGATOR',
          'Person who directs the route or course of a ship or trip',
          'Skilled celestial ocean navigator.',
        ),
        WordDef(
          'BACKPACKER',
          'Person who travels or hikes carrying their belongings',
          'Budget backpacker traveling the world.',
        ),
        WordDef(
          'TREASURE',
          'Quantity of precious metals, gems, or other valuable items',
          'Buried ancient pirate gold treasure.',
        ),
        WordDef(
          'EXCURSION',
          'Short journey or trip, especially one taken as leisure',
          'Day trip boating snorkeling excursion.',
        ),
        WordDef(
          'DESTINATION',
          'Place to which someone is going or being sent',
          'Reaching the remote final destination.',
        ),
        WordDef(
          'EXPLORATION',
          'The action of traveling in or through unfamiliar area',
          'Deep sea ocean trench exploration.',
        ),
        WordDef(
          'CHALLENGE',
          'Task or situation that tests someone abilities',
          'Conquering the grueling mountain challenge.',
        ),
        WordDef(
          'MOUNTAINEER',
          'Person who takes part in mountaineering as sport',
          'Experienced alpine summit mountaineer.',
        ),
        WordDef(
          'WATERFALL',
          'Cascade of water falling from a height down cliff',
          'Towering misty jungle waterfall.',
        ),
        WordDef(
          'RAINFOREST',
          'Dense evergreen forest with high annual rainfall',
          'Hiking through tropical rainforest canopy.',
        ),
        WordDef(
          'SHIPWRECK',
          'Destruction of a ship at sea by sinking or breaking up',
          'Exploring underwater coral encrusted shipwreck.',
        ),
        WordDef(
          'PARAGLIDER',
          'Non-motorized, foot-launched glider aircraft with canopy',
          'Soaring high above valleys on paraglider.',
        ),
        WordDef(
          'KAYAKING',
          'Sport or activity of paddling in a light narrow kayak',
          'Sea kayaking through remote Alaskan fjords.',
        ),
        WordDef(
          'SPELEOLOGY',
          'The scientific study or exploration of caves',
          'Subterranean limestone cave speleology.',
        ),
        WordDef(
          'ORIENTATION',
          'Determination of relative position with compass',
          'Wilderness map and compass orientation.',
        ),
        WordDef(
          'ENDURANCE',
          'The fact or power of enduring an unpleasant process',
          'Extreme endurance physical fitness.',
        ),
        WordDef(
          'CROSS COUNTRY',
          'Across fields or open country rather than on roads',
          'Skiing cross country winter trails.',
        ),
      ],
    ),

    // 30. Fantasy
    ChapterDef(
      id: 30,
      key: 'fantasy',
      title: 'Fantasy',
      iconAsset: 'assets/chapter_images/fantasy.png',
      themeColor: 0xFF9C27B0,
      shortWords: const [
        WordDef(
          'MAGE',
          'Magician or learned person using arcane spells',
          'Wise grand archmage casting spells.',
        ),
        WordDef(
          'ELF',
          'Supernatural creature with pointed ears and magic',
          'High elf archer in enchanted woods.',
        ),
        WordDef(
          'WAND',
          'Long, thin stick or rod used by magician in casting',
          'Carved oak wood spell casting wand.',
        ),
        WordDef(
          'ORC',
          'Brutish humanoid creature found in fantasy worlds',
          'Armored fierce orc warrior horde.',
        ),
        WordDef(
          'RUNE',
          'Letter of ancient alphabet believed to hold magic',
          'Glowing blue ancient stone magic rune.',
        ),
        WordDef(
          'MYTH',
          'Traditional story concerning early history or supernatural',
          'Ancient myth of creation and magic.',
        ),
        WordDef(
          'HERO',
          'Person admired for courage, bravery, and noble deeds',
          'Prophesied legendary fantasy hero.',
        ),
        WordDef(
          'TALE',
          'Fictitious or true narrative story of adventures',
          'Enchanting bard epic hero tale.',
        ),
        WordDef(
          'LORE',
          'Body of traditions and knowledge on fantasy realm',
          'Deep fantasy history and ancient lore.',
        ),
        WordDef(
          'CAST',
          'Direct or launch a magical spell at target',
          'Casting a protective shield spell.',
        ),
        WordDef(
          'RING',
          'Circular band of precious metal imbued with power',
          'One magic ring to rule them all.',
        ),
        WordDef(
          'SWORD',
          'Weapon with long metal blade and hilt with hand guard',
          'Forging legendary glowing steel sword.',
        ),
        WordDef(
          'BOW',
          'Weapon for shooting arrows, made of curved wood',
          'Elven longbow crafted from yew wood.',
        ),
        WordDef(
          'ORB',
          'Spherical globe of crystal glowing with magical energy',
          'Scrying future visions in crystal orb.',
        ),
        WordDef(
          'LAIR',
          'Wild animal or dragon resting place or secret den',
          'Entering the fiery red dragon lair.',
        ),
        WordDef(
          'FOE',
          'An enemy or opponent in combat or quest',
          'Defeating the dark sorcerer foe.',
        ),
        WordDef(
          'KING',
          'Male sovereign ruler of a kingdom or fantasy realm',
          'Rightful crowned king on the throne.',
        ),
        WordDef(
          'CROWN',
          'Ornamental circular headdress worn by a monarch',
          'Golden crown set with glowing rubies.',
        ),
        WordDef(
          'HELM',
          'Protective metal helmet worn by knights into battle',
          'Gleaming silver visor warrior helm.',
        ),
        WordDef(
          'TOME',
          'Large heavy book containing arcane spells and history',
          'Leather bound grimoire spell tome.',
        ),
      ],
      mediumWords: const [
        WordDef(
          'DRAGON',
          'Mythical monster like giant reptile breathing fire',
          'Fierce winged dragon guarding gold hoard.',
        ),
        WordDef(
          'WIZARD',
          'Man who has magical powers, especially in legends',
          'Grey bearded wizard carrying staff.',
        ),
        WordDef(
          'MAGIC',
          'Power of influencing course of events using mysteries',
          'Channeling raw elemental arcane magic.',
        ),
        WordDef(
          'SPELL',
          'Form of words used as magical charm or incantation',
          'Whispering a secret levitation spell.',
        ),
        WordDef(
          'POTION',
          'Liquid with healing, magical, or poisonous properties',
          'Brewing glowing green health potion.',
        ),
        WordDef(
          'CASTLE',
          'Large fortified building of medieval or fantasy lords',
          'Gothic stone castle on mountain cliff.',
        ),
        WordDef(
          'KNIGHT',
          'Man granted honorary title of knighthood with armor',
          'Chivalrous knight in shining plate armor.',
        ),
        WordDef(
          'SHIELD',
          'Broad piece of armor carried on arm to deflect blows',
          'Emblazoned heraldic crest iron shield.',
        ),
        WordDef(
          'PALACE',
          'Large, impressive residence of royalty or grand ruler',
          'Gilded golden royal emperor palace.',
        ),
        WordDef(
          'THRONE',
          'Ceremonial chair for a sovereign, bishop, or king',
          'Carved marble high royal throne.',
        ),
        WordDef(
          'ARMOR',
          'Metal coverings worn to protect body in battle',
          'Full suit of polished steel plate armor.',
        ),
        WordDef(
          'TEMPLE',
          'Building devoted to the worship of mythical gods',
          'Ancient ruined jungle sun temple.',
        ),
        WordDef(
          'GOBLIN',
          'Mischievous, ugly creature of folklore and fantasy',
          'Sneaky green goblin thief in dungeon.',
        ),
        WordDef(
          'SHADOW',
          'Dark figure or manifestation of dark magic',
          'Lurking shadow assassin in the dark.',
        ),
        WordDef(
          'PRINCE',
          'Son of a monarch or royal dynasty',
          'Brave young warrior kingdom prince.',
        ),
        WordDef(
          'SCYTHE',
          'Tool or weapon with long curved blade used by reapers',
          'Dark spectral reaper wielding scythe.',
        ),
        WordDef(
          'TALISMAN',
          'Object held to act as charm to avert evil or bring luck',
          'Engraved silver protective talisman.',
        ),
        WordDef(
          'AMULET',
          'Ornament or small piece of jewelry thought to give power',
          'Glowing blue crystal protective amulet.',
        ),
        WordDef(
          'SPIRIT',
          'Non-physical supernatural entity or ghost',
          'Guiding ancestral spirit of the woods.',
        ),
        WordDef(
          'PORTAL',
          'Doorway, gate, or magical doorway into other dimensions',
          'Stepping through swirling magic portal.',
        ),
      ],
      longWords: const [
        WordDef(
          'SORCERER',
          'Person who claims or is believed to have magic powers',
          'Dark hooded sorcerer conjuring flames.',
        ),
        WordDef(
          'ENCHANTED',
          'Filled with delight; placed under a magical spell',
          'Wandering into the enchanted whispering forest.',
        ),
        WordDef(
          'MYTHOLOGY',
          'Collection of myths belonging to particular religion',
          'Studying legendary Norse mythology.',
        ),
        WordDef(
          'LEGENDARY',
          'Remarkable enough to be famous; described in legend',
          'Wielding legendary Excalibur sword.',
        ),
        WordDef(
          'SPELLBOOK',
          'Book containing instructions for casting magic spells',
          'Dusty leather grimoire spellbook.',
        ),
        WordDef(
          'UNIVERSE',
          'All existing matter and space considered as a whole',
          'Expanding multiverse fantasy universe.',
        ),
        WordDef(
          'KINGDOM',
          'Country, state, or territory ruled by a king or queen',
          'Defending the peaceful fantasy kingdom.',
        ),
        WordDef(
          'EXCALIBUR',
          'The legendary magical sword of King Arthur',
          'Pulling Excalibur from the stone.',
        ),
        WordDef(
          'CENTAUR',
          'Mythological creature with upper body of man and horse',
          'Wise centaur archer galloping in forest.',
        ),
        WordDef(
          'GRIFFIN',
          'Mythical creature with head and wings of eagle and lion',
          'Regal griffin perched atop high cliff.',
        ),
        WordDef(
          'PEGASUS',
          'Mythical winged divine stallion pure white horse',
          'Flying on the back of majestic Pegasus.',
        ),
        WordDef(
          'PHOENIX',
          'Mythical bird that burns and rises from its ashes',
          'Immortal fiery phoenix rising reborn.',
        ),
        WordDef(
          'MINOTAUR',
          'Mythical monster with head of a bull and body of a man',
          'Navigating the labyrinth of Minotaur.',
        ),
        WordDef(
          'LABYRINTH',
          'Complicated irregular network of passages or maze',
          'Escaping the winding stone labyrinth.',
        ),
        WordDef(
          'VALKYRIE',
          'Each of Odin maidens who conducted slain heroes to Valhalla',
          'Winged warrior Valkyrie on battlefield.',
        ),
        WordDef(
          'GARGOYLE',
          'Grotesque carved human or animal face on building',
          'Stone gargoyle perching on cathedral roof.',
        ),
        WordDef(
          'LEPRECHAUN',
          'Mischievous elf of Irish folklore hiding pot of gold',
          'Catching the clever gold leprechaun.',
        ),
        WordDef(
          'NECROMANCER',
          'Wizard who practices magic of raising the dead',
          'Confronting dark army of necromancer.',
        ),
        WordDef(
          'SANCTUARY',
          'Sacred place offering refuge from danger or evil',
          'Protected inside the holy sanctuary.',
        ),
        WordDef(
          'TRANSFORMATION',
          'Thorough or dramatic change in form or appearance',
          'Magical shapeshifting transformation.',
        ),
      ],
    ),
  ];
}
