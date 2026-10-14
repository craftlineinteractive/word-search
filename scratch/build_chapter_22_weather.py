import json
import os
import random

ch_files = {
    1: "assets/data/chapter_01_food.json",
    2: "assets/data/chapter_02_holiday.json",
    3: "assets/data/chapter_03_jobs.json",
    4: "assets/data/chapter_04_electronics.json",
    5: "assets/data/chapter_05_books.json",
    6: "assets/data/chapter_06_games.json",
    7: "assets/data/chapter_07_plants.json",
    8: "assets/data/chapter_08_painting.json",
    9: "assets/data/chapter_09_words.json",
    10: "assets/data/chapter_10_professional.json",
    11: "assets/data/chapter_11_religion.json",
    12: "assets/data/chapter_12_music.json",
    13: "assets/data/chapter_13_hobby.json",
    14: "assets/data/chapter_14_nature.json",
    15: "assets/data/chapter_15_tournament.json",
    16: "assets/data/chapter_16_education.json",
    17: "assets/data/chapter_17_technology.json",
    18: "assets/data/chapter_18_birds.json",
    19: "assets/data/chapter_19_pets.json",
    20: "assets/data/chapter_20_wild-animals.json",
    21: "assets/data/chapter_21_ocean.json",
}

used_words = set()
for c_num, path in ch_files.items():
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            for lvl in data.get('levels', []):
                for w in lvl.get('words', []):
                    used_words.add(w['word'].upper())

print(f"Total used words in prior chapters (1-21): {len(used_words)}")

# Curated pool of 100% distinct, standalone weather & atmospheric terms.
# NO ...TIME, NO ...WEATHER, NO ...DAY, NO ...NIGHT, NO ...WIND, NO ...AIR, NO ...RAIN, NO ...SNOW, NO pattern family duplicates.

raw_weather_words = [
    # Basic Descriptors
    ("SUNNY", "Bright sky filled with abundant sunshine and clear light", "The sunny morning encouraged everyone to go for a park walk."),
    ("RAINY", "Characterized by frequent falling rain showers", "A rainy afternoon called for cozy warm tea indoors."),
    ("CLOUDY", "Sky covered heavily with visible clouds blocking direct sun", "The overcast cloudy sky signaled an approaching rain shower."),
    ("STORMY", "Accompanied by strong winds, rain, lightning, or thunder", "The stormy weather rattled window panes throughout the night."),
    ("BREEZY", "Pleasantly fresh with light gentle blowing wind", "A breezy autumn afternoon rustled red leaves across the lawn."),
    ("WINDY", "Exposed to strong gusts of blowing air", "The windy mountain peak blew hats off hikers."),
    ("FOGGY", "Thick low mist reducing visibility near the ground", "Drivers slowed down cautiously on the foggy coastal highway."),
    ("MISTY", "Covered with fine droplets of water suspended in air", "The misty valley morning looked serene and peaceful."),
    ("HAZY", "Obscured by fine dust, smoke, or light heat moisture", "The hazy summer horizon shimmered under midday sun."),
    ("CHILLY", "Uncomfortably cool temperature requiring a jacket", "A chilly evening breeze ushered in the arrival of autumn."),
    ("BALMY", "Pleasantly warm, gentle, and refreshing weather", "The balmy tropical breeze made evening walks delightful."),
    ("MUGGY", "Warm and uncomfortably humid atmospheric conditions", "The muggy summer air made everyone long for air conditioning."),
    ("HUMID", "Containing a high level of water vapor moisture in air", "High humid weather caused sticky moisture on windows."),
    ("SQUALLY", "Characterized by sudden sharp bursts of wind and rain", "Squally ocean winds rocked small fishing boats in the harbor."),
    ("DUSTY", "Air filled with fine airborne sand or soil particles", "A dusty wind blew across dry desert roads."),
    ("SULTRY", "Hot and uncomfortably humid weather conditions", "The sultry summer evening felt heavy before the thunderstorm."),
    ("CLEAR", "Unobscured sky free of clouds, fog, or precipitation", "A clear blue sky welcomed early morning runners."),
    ("GUSTY", "Blowing in sudden strong irregular bursts of wind", "Gusty winds blew loose papers down the city street."),
    ("FREEZING", "Extremely cold temperature at or below ice melting point", "Freezing night temperatures turned rain into slick black ice."),
    ("SCORCHING", "Intensely hot sunshine creating extreme heat", "Scorching desert heat reached over one hundred degrees."),
    ("SWELTERING", "Uncomfortably hot and oppressive atmospheric heat", "Sweltering afternoon sunshine kept people inside shaded pools."),
    ("POLAR", "Relating to cold regions around North or South Pole", "Polar air masses brought sub-zero temperatures south."),
    ("COOL", "Moderately low temperature that is pleasantly refreshing", "A cool breeze refreshed runners after the race."),
    ("DAMP", "Slightly wet air or ground moisture after rain", "Damp air filled the forest after morning drizzle."),
    ("DRY", "Free from moisture or rainfall", "Dry desert air made hot summer days bearable."),
    ("WET", "Covered or saturated with water or rain", "Wet pavements reflected bright streetlights at night."),
    ("FRESH", "Clean, crisp, and cool air quality after rain", "Fresh morning air filled the open bedroom window."),
    ("SHADOW", "Dark area formed where cloud blocks sunlight", "Cloud shadows swept across green rolling hills."),
    ("GLOOM", "Dim light or dark cloudy atmosphere", "The gloom of the storm cloud darkened afternoon skies."),
    ("SHINE", "Emit bright light or clear sunshine", "Bright sun shine lit up the morning meadow."),
    ("GLIMMER", "Faint or wavering light breaking through cloud cover", "A glimmer of sunshine broke through dark storm clouds."),
    ("BLAST", "Sudden strong gust or blow of wind air", "A blast of icy wind hit us at the mountain peak."),
    ("WHIRL", "Rotate or spin rapidly like wind in a vortex", "Leaves began to whirl in the playful autumn breeze."),
    ("ROAR", "Loud deep sound made by strong gale winds", "The roar of the storm wind echoed through the valley."),
    ("HOWL", "Produce long loud wailing sound in wind", "Cold night winds began to howl through pine branches."),
    ("CRASH", "Loud sharp noise of thunder breaking overhead", "A sharp crash of thunder shook the house walls."),
    ("DENSE", "Thick and difficult to see through fog or cloud", "Dense fog covered the bay reducing visibility to zero."),
    ("THICK", "Heavy and crowded cloud or fog layer", "Thick fog slowed morning harbor traffic."),
    ("HEAVY", "Great in amount or force such as heavy rain", "Heavy rain filled rain barrels in the garden."),
    ("MILD", "Gentle and moderate weather temperature", "Mild spring weather brought green shoots out of soil."),
    ("FAIR", "Pleasant and clear weather without rain", "Fair weather was predicted for the weekend outdoor festival."),
    ("STILL", "Not moving or windless atmospheric state", "Still air hung over the quiet forest at dusk."),
    ("QUIET", "Silent and peaceful weather environment", "A quiet snowfall covered city streets overnight."),
    ("SHADY", "Sheltered from direct hot sunlight by trees", "A shady oak tree provided relief from midday heat."),
    ("SNOWY", "Covered with or characterized by falling snow", "A snowy landscape greeted us on Christmas morning."),
    ("CRISP", "Pleasantly cool, dry, and clear air quality", "Crisp autumn air made sweater weather enjoyable."),
    ("DREARY", "Dull, bleak, and depressing weather atmosphere", "A dreary overcast day kept people indoors."),
    ("SOMBER", "Dark, gloomy, and dull sky conditions", "Somber storm clouds darkened the evening horizon."),
    ("RAW", "Uncomfortably cold and damp atmospheric air", "A raw winter wind chilled spectators at the stadium."),
    ("TORRENTIAL", "Falling in heavy fast-rushing rain streams", "Torrential rain flooded low-lying streets in minutes."),
    ("PARCHED", "Extremely dry and lacking moisture due to heat or drought", "Parched garden soil cracked under weeks of hot sunshine."),
    ("STIFLING", "Oppressively hot and humid air making breathing difficult", "Stifling heat filled the unventilated attic room."),
    ("FRIGID", "Extremely cold in temperature like polar ice", "Frigid arctic winds chilled the town overnight."),
    ("BITTER", "Stinging, harsh, and biting cold air quality", "Bitter wind chill values made winter morning walks tough."),
    ("ARID", "Lacking sufficient rainfall for vegetation growth", "Arid desert regions receive less than ten inches of rain annually."),
    ("TROPICAL", "Belonging to warm humid equatorial climate regions", "Tropical weather brings warm ocean waters and frequent rain."),
    ("EQUATORIAL", "Located near Earth equator featuring high warmth and rain", "Equatorial forests stay warm and humid year round."),
    ("MARITIME", "Influenced heavily by proximity to ocean waters", "Maritime climates feature mild winters and cool summers."),
    ("CONTINENTAL", "Climate of land far from sea with wide temp range", "Continental climates experience hot summers and cold winters."),

    # Hydrology, Water & Ice
    ("HAIL", "Pellets of frozen ice falling during severe thunderstorms", "Heavy hail bounced off car windshields during the storm."),
    ("DELUGE", "Severe flood or heavy torrential downpour of rain", "The tropical deluge poured inches of water onto coastal towns."),
    ("OVERFLOW", "Flow over margin or banks due to excess water", "Heavy rains caused garden rain barrels to overflow."),
    ("RIPPLE", "Small wave or wavelets on water surface caused by breeze", "A light breeze created gentle ripples on lake water."),
    ("SPRAY", "Fine ocean or rain water droplets blown by wind", "Sea spray flew off crashing ocean waves."),
    ("DRIZZLING", "Raining lightly in very small fine droplets", "It was drizzling softly as we walked through the park."),
    ("FLURRY", "Brief light snowfall accompanied by gentle wind gusts", "A light snow flurry dusted pine tree branches."),
    ("ICE", "Frozen solid water formed by cold freezing temperatures", "Thick ice covered the surface of the mountain lake."),
    ("ICY", "Covered with slick dangerous frozen ice", "Icy roads required slow driving after night freezing."),
    ("GLAZE", "Smooth thin coating of clear ice formed by freezing rain", "Freezing rain left a shiny glaze over tree limbs."),
    ("SLUSH", "Partially melted soft watery snow on ground", "Melting snow turned city sidewalks into messy slush."),
    ("MELTWATER", "Water resulting from melting of snow or ice", "Rushing meltwater filled mountain creek channels in spring."),
    ("RUNOFF", "Draining away of rain water from land into streams", "Heavy rain runoff flowed down hillside drainage ditches."),
    ("PUDDLE", "Small shallow pool of rain water on ground surface", "Children splashed joyfully in rain puddles after the storm."),
    ("CANAL", "Artificial waterway built for drainage or irrigation", "Rain water filled irrigation canals across farm fields."),
    ("MOISTURE", "Water or liquid diffused in small quantity as vapor", "High soil moisture helped spring flowers bloom vibrant colors."),
    ("DEWDROP", "Tiny bead of condensed water formed on cool surfaces", "Morning dewdrop beads sparkled on green grass blades."),
    ("FROST", "Deposit of minute ice crystals formed on frozen objects", "Morning frost decorated window glass with delicate patterns."),
    ("VERGLAS", "Thin coating of transparent ice on rock or pavement", "Hiker boots slipped on hidden mountain verglas."),
    ("GRAUPEL", "Soft snow pellets formed when supercooled water freezes on snowflakes", "White graupel pellets rattled down during the cold shower."),
    ("RIME", "Frost deposit formed by rapidly freezing fog droplets", "Rime ice coated mountain observatory radio towers."),
    ("WHITEOUT", "Blinding blizzard condition where earth and sky blend in white", "Drivers stopped safely during the sudden mountain whiteout."),
    ("BLACKICE", "Transparent coating of thin ice on road surfaces dangerous to drivers", "Cars slowed down to avoid invisible blackice on the bridge."),
    ("CONDENSATE", "Liquid drops resulting from cooling of water vapor", "Cool glass collected clear condensate droplets from warm air."),
    ("EVAPORATION", "Process of liquid water turning into vapor gas", "Solar heat speeds up evaporation from surface lakes."),
    ("SUBLIMATION", "Transition of ice directly into water vapor gas", "High altitude dry air caused snow sublimation on mountain peaks."),
    ("DRAINAGE", "System for carrying away surface water after rainstorms", "City street drainage prevented standing water after heavy rain."),
    ("VAPOR", "Water diffused or suspended in air as gas", "Warm water vapor rose from the sunny lake."),
    ("ICEBERG", "Large floating mass of ice detached from glacier into sea", "The ship altered course to avoid a massive polar iceberg."),
    ("GLACIER", "Slowly moving river of dense ice formed by snow accumulation", "The glacier carved a deep V-shaped valley through the mountains."),
    ("ICEFIELD", "Extensive expanse of interconnected glaciers covering mountains", "An immense icefield covered the high mountain plateau."),
    ("ICEFLOE", "Large flat sheet of floating sea ice drifting with ocean current", "Seals hauled out onto a floating icefloe to rest."),
    ("PACKICE", "Mass of large floating ice pieces driven together by wind", "The research vessel navigated carefully through thick packice."),
    ("SERAC", "Pinnacle or tower of ice on a glacier formed by crevasses", "Climbers avoided towering serac ice blocks on the icefall."),
    ("CREVASSE", "Deep open crack or fissure in glacier ice", "Roped climbers stepped carefully across a snow-covered crevasse."),
    ("CIRQUE", "Amphitheater hollow carved into mountain peak by glacier erosion", "A clear tarn lake formed inside the alpine cirque basin."),
    ("MORAINE", "Accumulation of boulders and debris deposited by glacier", "The lateral moraine marked the former boundary of the glacier."),
    ("OUTWASH", "Deposit of sand and gravel washed out by glacial meltwater", "Braided streams crisscrossed the broad glacial outwash plain."),
    ("SOLIFLUCTION", "Gradual downhill movement of water-logged soil over permafrost", "Solifluction created terraced soil patterns on tundra slopes."),
    ("MUDFLOW", "Rushing fluid stream of mud and debris after torrential rain", "Heavy monsoon rain triggered a destructive hillside mudflow."),
    ("WASHOUT", "Erosion of roadbed or soil by heavy rainfall runoff", "Torrential rain caused a road washout near the river bridge."),
    ("GULLY", "Trench worn into hillside land by running water after rain", "Rain runoff carved a deep gully across the farm field."),
    ("ARROYO", "Dry creek bed that fills with rushing water during flash floods", "Desert hikers avoided camping inside the dry arroyo bed."),
    ("CANYON", "Deep valley with steep cliff sides carved by river water", "The river carved a dramatic rock canyon over millions of years."),
    ("ESTUARY", "Tidal mouth of large river where freshwater meets sea water", "The coastal estuary provided a rich nursery for fish and birds."),
    ("LAGOON", "Shallow body of water separated from sea by coral reef or sandbar", "Warm turquoise water filled the calm tropical lagoon."),
    ("SWAMP", "Wetland forest area flooded continuously with water", "Cypress trees grew out of the murky swamp waters."),
    ("MARSH", "Wetland area dominated by tall grasses and reeds", "Red-winged blackbirds nested in the coastal reed marsh."),
    ("BOG", "Wetland area featuring acidic peat soil fed by rainwater", "Sphagnum moss carpeted the quiet acidic peat bog."),
    ("FEN", "Wetland area featuring mineral-rich peat soil fed by groundwater", "Rare orchids bloomed in the alkaline fen meadow."),
    ("DELTA", "Landform formed by sediment deposition at river mouth", "The fertile river delta supported rich agricultural fields."),
    ("MEANDER", "Winding curve or loop in course of river", "The lazy river formed a wide meander through green pastures."),
    ("OXBOW", "U-shaped lake formed when river meander loop is cut off", "An oxbow lake formed where the old river channel separated."),
    ("RIPARIAN", "Relating to or located on banks of natural river course", "Willow trees lined the green riparian zone along the stream."),
    ("LITTORAL", "Coastal region subject to action of waves and tides", "Intertidal crabs scavenged along the rocky littoral shore."),
    ("FLUVIAL", "Relating to or produced by river currents and running water", "Fluvial deposits formed fertile gravel beds along the riverbank."),
    ("LACUSTRINE", "Relating to or associated with lakes and pond environments", "Core samples revealed historic lacustrine sediment layers."),
    ("ABYSSAL", "Deep ocean floor environment below two thousand meters", "Bizarre sea life inhabited the cold dark abyssal plain."),
    ("NERITIC", "Shallow sea zone over continental shelf supporting abundant life", "Commercial fishing boats worked the productive neritic waters."),
    ("INUNDATION", "Rising and overflowing of water bodies covering surrounding land", "Seasonal river inundation created temporary wetland habitats for migratory birds."),
    ("AQUIFER", "Underground layer of rock holding groundwater", "Winter rains replenished the deep agricultural aquifer."),

    # Biomes, Climate Regions & Geographic Landforms
    ("TAIGA", "Subarctic coniferous forest biome experiencing long cold winters", "Dense evergreen pine trees stretched across the vast northern taiga."),
    ("TUNDRA", "Treeless polar plain biome featuring frozen subsoil permafrost", "Mosses and lichens carpeted the open arctic tundra landscape."),
    ("SAVANNA", "Tropical grassland biome featuring scattered trees and wet-dry seasons", "Herds grazed across the golden savanna during dry season."),
    ("STEPPE", "Semi-arid temperate grassland plain receiving modest rainfall", "Cool breezes blew across the endless green steppe pasture."),
    ("PRAIRIE", "Temperate grassland plain of fertile soil and rolling hills", "Tall native grasses swayed across the midwestern prairie."),
    ("PAMPAS", "Fertile South American plains experiencing temperate climate", "Cattle roamed the vast agricultural pampas of Argentina."),
    ("CHAPARRAL", "Coastal shrubland biome featuring hot dry summers and mild wet winters", "Fragrant sage and scrub oak covered the sunny chaparral hills."),
    ("DESERT", "Arid barren region receiving extremely low annual precipitation", "Saguaro cacti stored precious water in the Sonoran desert."),
    ("RAINFOREST", "Dense tropical forest receiving high rainfall year round", "Abundant rain nourished the lush canopy of the Amazon rainforest."),
    ("CLOUDFOREST", "High elevation tropical forest enveloped in continuous mountain fog", "Orchids and ferns thrived in the damp mountain cloudforest."),
    ("WOODLAND", "Open forest land with sunny openings between trees", "Wildflowers bloomed under the canopy of the oak woodland."),
    ("HEATH", "Open uncultivated land covered with low shrubby vegetation", "Purple heather covered the windy coastal heathland."),
    ("MOORLAND", "High open uncultivated highland area with acidic peat soil", "Cool mists drifted over the quiet Scottish moorland."),
    ("ALPINE", "High mountain climate zone above the natural tree growth line", "Wildflowers bloomed briefly in alpine meadows after snow melt."),
    ("SUBALPINE", "Mountain zone immediately below treeline featuring stunted trees", "Wind-bent pine trees grew along the rugged subalpine ridge."),
    ("MONTANE", "Relating to or inhabiting cool moist mountain slopes", "Lush fir trees dominated the cool montane forest zone."),
    ("PIEDMONT", "Gentle sloping plateau region at foot of mountain range", "Rolling hills formed the fertile piedmont east of the mountains."),
    ("PLATEAU", "Elevated level expanse of land rising above surrounding terrain", "Cool breezes swept across the high desert plateau."),
    ("VALLEY", "Low area of land between hills or mountains often with river", "A winding river flowed through the green mountain valley."),
    ("BASIN", "Depressed area of Earth surface surrounded by higher land", "Heavy rainfall collected in the natural drainage basin."),

    # Meteorology & Geophysical Disciplines
    ("CLIMATOLOGY", "Scientific study of climate and long-term weather patterns", "Climatology records document global temperature trends over centuries."),
    ("GLACIOLOGY", "Scientific study of glaciers, ice sheets, and polar ice caps", "Glaciology research measures polar ice sheet thickness."),
    ("OCEANOGRAPHY", "Scientific study of physical and biological aspects of sea", "Oceanography vessels map deep sea floor currents and temperatures."),
    ("GEOPHYSICS", "Physics of Earth planet including atmosphere and magnetosphere", "Geophysics sensors detect magnetic field variations in upper sky."),

    # Geographical, Atmospheric Scales & Geographic Coordinates
    ("ALTITUDE", "Vertical height of an atmospheric level or plane above sea level", "Air pressure decreases predictably as altitude increases."),
    ("ELEVATION", "Height of a land surface feature above mean ocean sea level", "High mountain elevation created cool summer temperatures."),
    ("LATITUDE", "Angular distance north or south of Earth equator influencing climate", "High latitude regions experience short winter daylight hours."),
    ("LONGITUDE", "Angular distance east or west of prime meridian", "Longitude coordinates helped plot the hurricane movement path."),
    ("EQUATOR", "Imaginary circle around Earth receiving maximum solar heat", "Warm ocean waters near the equator fuel tropical weather systems."),
    ("TROPICS", "Region between Tropic of Cancer and Tropic of Capricorn", "Abundant rain and warm sun nourish lush tropical forests."),
    ("PHENOLOGY", "Study of periodic plant and animal life cycle events driven by climate", "Phenology tracks spring bloom dates across regional ecosystems."),
    ("BIOME", "Major regional ecological community shaped by temperature and rainfall", "Tundra and savanna represent major terrestrial biomes on Earth."),

    # Seasons, Cloud Types, Storms & Atmospheric Phenomena
    ("SUMMER", "Warmest season of year between spring and autumn", "Summer sunshine brought crowds of swimmers to the beach."),
    ("WINTER", "Coldest season of year between autumn and spring", "Winter snow covered forest trees in white blankets."),
    ("SPRING", "Season of growth when flowers bloom after winter", "Spring rain helped garden seeds sprout green shoots."),
    ("AUTUMN", "Season of falling leaves between summer and winter", "Autumn winds blew colorful orange leaves across lawns."),
    ("LIGHTNING", "Flash of atmospheric electricity during a thunderstorm", "A jagged bolt of lightning illuminated the dark storm sky."),
    ("THUNDER", "Loud rumbling sound caused by lightning expansion", "Peals of thunder echoed across the mountain valley."),
    ("RAINBOW", "Arc of spectral colors formed by light refraction in water drops", "A vivid double rainbow appeared across the sky after storm."),
    ("AVALANCHE", "Mass of snow and ice sliding rapidly down a mountain slope", "Skiers were warned of avalanche dangers after heavy snowfall."),
    ("LANDSLIDE", "Sliding down of mass of earth or rock from mountain slope", "Torrential rainfall triggered a hillside landslide onto the road."),
    ("FORECAST", "Prediction of upcoming atmospheric weather conditions", "The evening forecast predicted sunshine for the weekend."),
    ("RADAR", "System using radio waves to detect precipitation and storm tracks", "Weather radar tracked severe thunderstorm cells moving east."),
    ("SATELLITE", "Orbiting spacecraft gathering global cloud and weather images", "Geostationary satellites monitor hurricane paths continuously."),
    ("ISOTHERM", "Line on weather map connecting points of equal temperature", "The zero-degree isotherm marked the boundary of freezing air."),
    ("AURORA", "Luminous atmospheric light phenomenon near polar regions", "Green aurora light waves danced across the northern night sky."),
    ("GLOW", "Soft warm light emitted by atmosphere at twilight", "A golden glow lingered along the horizon after sunset."),
    ("HALO", "Ring of light encircling sun or moon caused by ice crystals", "A bright optical halo surrounded the moon through cirrus clouds."),
    ("TWILIGHT", "Soft diffused light from sky between sunset and full darkness", "Evening twilight lit up the western sky in pastel shades."),
    ("DAWN", "First appearance of light in morning sky before sunrise", "Birds began singing at dawn as morning light filled the sky."),
    ("DUSK", "Period of fading light at evening twilight before dark", "Streetlights turned on automatically at dusk."),
    ("CUMULUS", "Puffy white clouds with flat bases and rounded tops", "Fair weather cumulus clouds drifted across summer skies."),
    ("STRATUS", "Low flat uniform cloud layer covering sky like gray sheet", "Dull gray stratus clouds brought continuous light drizzle."),
    ("CIRRUS", "High wispy cloud filaments formed of delicate ice crystals", "Thin cirrus clouds swept across high altitude skies."),
    ("NIMBUS", "Dark rain-bearing cloud mass", "Dark nimbus clouds gathered before the storm broke."),
    ("ALTOCUMULUS", "Middle altitude cloud deck featuring grey sheet tufts", "Altocumulus clouds formed a dappled mackerel sky pattern."),
    ("ALTOSTRATUS", "Greyish uniform cloud sheet obscuring sun weakly", "Altostratus cloud cover dimmed afternoon sunshine into gray glow."),
    ("CIRROCUMULUS", "High small white cloud patches producing ripple effect", "Cirrocumulus ripples sparkled brightly in the afternoon sky."),
    ("CIRROSTRATUS", "High thin transparent cloud veil producing sun halo", "Cirrostratus cloud veils presaged an approaching warm front."),
    ("STRATOCUMULUS", "Low lumpy cloud layer with dark patchwork patches", "Stratocumulus cloud decks rolled over coastal waters."),
    ("CUMULONIMBUS", "Towering thunderstorm cloud capable of heavy rain and lightning", "A giant cumulonimbus cloud built rapidly into an anvil shape."),
    ("SUNSHINE", "Direct light and warmth received from sun", "Warm sunshine brightened afternoon park picnics."),
    ("SUNBEAM", "Ray of sunlight breaking through cloud openings", "A single sunbeam lit up the forest floor."),
    ("SUNLIGHT", "Light emanating directly from sun", "Morning sunlight filtered through open bedroom curtains."),
    ("HORIZON", "Line where Earth surface and sky appear to meet", "The sun dipped below the ocean horizon at sunset."),
    ("DRAFT", "Current of air moving through an enclosed space or sky", "A cool draft blew through the open porch window."),
    ("UPDRAFT", "Rising vertical current of warm air feeding storm clouds", "Strong storm updrafts lifted rain droplets high into freezing air."),
    ("TORNADO", "Violently rotating column of air extending from thunderstorm to ground", "A severe tornado swept through open farm fields."),
    ("TWISTER", "Colloquial term for a violent spinning tornado cyclone", "Storm spotters tracked the twister across rural country roads."),
    ("CYCLONE", "System of winds rotating inward around low pressure center", "A tropical cyclone brought strong winds and heavy rainfall."),
    ("TYPHOON", "Severe tropical cyclone occurring in western Pacific Ocean", "The typhoon generated huge ocean waves along the coast."),
    ("HURRICANE", "Severe tropical storm with winds exceeding seventy-four miles per hour", "Coastal residents prepared for hurricane landfall."),
    ("DEGREES", "Units of measurement for temperature on Celsius or Fahrenheit scale", "The afternoon temperature rose by ten degrees."),
    ("SOLSTICE", "Time of year when sun reaches highest or lowest excursion", "Summer solstice marks the longest day of daylight."),
    ("EQUINOX", "Time of year when day and night are equal length", "Spring equinox brought equal daylight and darkness."),
    ("WARMTH", "Pleasant state of moderate atmospheric heat", "The gentle warmth of spring sunshine felt refreshing."),
    ("MONSOON", "Seasonal wind pattern causing heavy summer rains in South Asia", "Monsoon rains replenished agricultural water supplies."),
    ("BLIZZARD", "Severe snowstorm featuring high gale winds and near zero visibility", "A fierce blizzard buried mountain roads in deep snow drifts."),
    ("ZEPHYR", "Gentle light mild breeze blowing from west", "A soft zephyr rustled flower petals in the garden."),
    ("GALE", "Very strong blowing wind velocity between thirty-four and forty-seven knots", "Gale force winds whipped heavy waves against harbor breakwaters."),
    ("TEMPEST", "Violent windy storm accompanied by heavy rain or snow", "The raging tempest battered coastal cliffs all night."),
    ("HABOOB", "Intense sandstorm created by thunderstorm downdrafts in arid land", "A wall of sand swept over the desert city during the haboob."),
    ("SIROCCO", "Hot dry dust-laden Mediterranean wind from Sahara desert", "Warm sirocco winds carried Saharan dust to southern European shores."),
    ("MISTRAL", "Strong cold north wind blowing down to Mediterranean coast", "The crisp mistral wind cleared clouds over valley vineyards."),
    ("CHINOOK", "Warm dry wind blowing down eastern Rocky Mountain slopes", "A chinook wind raised winter temperatures by thirty degrees."),
    ("PERMAFROST", "Permanently frozen subsoil layer found in polar regions", "Arctic tundra vegetation grows over deep permafrost."),
    ("HOARFROST", "Needle-like ice crystal deposit formed on objects by freezing vapor", "Intricate hoarfrost patterns coated tree branches at dawn."),
    ("DOWNPOUR", "Heavy sudden pouring rainfall", "A torrential downpour soaked city streets in minutes."),

    # Clouds & Atmospheric Structure
    ("ANVIL", "Flat spreading top section of a mature thunderstorm cloud", "The anvil top of the storm cloud reached high into sky."),
    ("SMOG", "Hazy air pollution mixture of smoke and fog particles", "City smog reduced air clarity on windless summer days."),
    ("OVERCAST", "Sky completely covered and darkened with thick clouds", "The overcast sky kept temperatures cool all day long."),
    ("CEILING", "Height of lowest cloud layer above ground level", "Pilots checked the low cloud ceiling before takeoff."),
    ("FLUFFY", "Soft and puffy cloud appearance like cotton balls", "Fluffy white clouds drifted slowly across blue skies."),
    ("LAYER", "Sheet or stratum of cloud cover spreading across sky", "A thin cloud layer muted the bright morning sunshine."),
    ("BANK", "Massive pile or ridge of fog or storm cloud", "A heavy bank of sea fog rolled over the harbor."),
    ("SHEET", "Broad continuous expanse of cloud or lightning flash", "A sheet of lightning lit up the entire night sky."),
    ("VEIL", "Thin translucent cloud layer partially covering sun", "A delicate cloud veil softened the afternoon glare."),
    ("SHROUD", "Covering or envelope of fog concealing landscape", "Thick mountain fog wrapped the valley in a white shroud."),
    ("DOME", "Hemispherical high pressure air mass or clear sky", "A high pressure heat dome lingered over central plains."),
    ("SKYLINE", "Outline of horizon where sky meets land or buildings", "Storm clouds gathered above the city skyline."),
    ("SUNBURST", "Sudden burst of bright sunlight breaking through clouds", "A brilliant sunburst illuminated the mountain valley."),
    ("DAYLIGHT", "Natural light present during hours of day", "Long daylight hours allowed extra evening garden work."),
    ("DAYTIME", "Period between sunrise and sunset when sun shines", "Warm daytime temperatures encouraged beach visits."),
    ("NOONTIDE", "Middle of day when sun reaches highest point", "Bright noontide sun cast short shadows under trees."),
    ("AFTERNOON", "Period of day between noon and evening", "A warm afternoon breeze blew through open windows."),
    ("MAMMATUS", "Pouch-like cloud structures hanging beneath thunderstorm anvils", "Bulbous mammatus clouds glowed pink during storm sunset."),
    ("LENTICULAR", "Lens-shaped smooth clouds forming over mountain peaks", "A stack of lenticular clouds hovered over the volcano peak."),
    ("ARCUS", "Low horizontal shelf cloud forming along thunderstorm edges", "A dark arcus cloud shelf rolled in with thunder gusts."),
    ("WATERSPOUT", "Swirling column of air and mist rotating over water", "A tall waterspout churned ocean water off the Florida coast."),
    ("FUNNEL", "Cone-shaped rotating cloud extending downward from storm", "A funnel cloud descended toward open prairie fields."),
    ("TROPOSPHERE", "Lowest layer of Earth atmosphere where weather occurs", "All cloud formations and storms occur within the troposphere."),
    ("FIRMAMENT", "The vault of heaven or expanse of the sky", "Stars shone brightly across the clear night firmament."),
    ("NOCTILUCENT", "High altitude night-shining ice clouds in mesosphere", "Rare noctilucent clouds glowed silvery blue after sunset."),
    ("NACREOUS", "Mother-of-pearl polar stratospheric clouds displaying vivid colors", "Nacreous clouds iridescently lit up the Arctic winter sky."),
    ("STRATIFORM", "Layered flat cloud structure spreading horizontally", "Stratiform cloud decks covered the valley from ridge to ridge."),
    ("CUMULIFORM", "Heaped puffy cloud formation with distinct vertical growth", "Cumuliform clouds built rapidly under strong afternoon heat."),
    ("CIRRIFORM", "Wispy fibrous cloud structures composed of ice crystals", "Cirriform clouds trailed delicate white feathers across high sky."),
    ("CONGESTUS", "Towering cumulus cloud showing strong vertical growth", "Cumulus congestus clouds towered upward into storm clouds."),
    ("CASTELLANUS", "Cloud featuring castle-like turrets indicating air instability", "Altocumulus castellanus clouds signaled morning storm risk."),
    ("ASPERITAS", "Wavy dark chaotic cloud undersides producing dramatic skies", "Asperitas cloud waves rolled dramatically over the prairie."),
    ("CAVUM", "Fallstreak hole or clear gap opening inside cloud deck", "A circular cavum hole formed as ice crystals fell through cloud."),
    ("FLUCTUS", "Kelvin-Helmholtz ocean-like wave cloud structures", "Parallel fluctus wave clouds formed along the wind shear zone."),
    ("CONTRAIL", "Condensation trail formed in sky by high altitude aircraft", "White contrail streaks crisscrossed the clear blue sky."),
    ("HUMILIS", "Small flattened cumulus clouds of fair weather", "Cumulus humilis clouds floated lazily over the summer meadow."),
    ("MEDIOCRIS", "Cumulus cloud of moderate vertical extent", "Cumulus mediocris clouds showed moderate vertical growth."),
    ("CALVUS", "Cumulonimbus cloud top with soft rounded outline", "The storm cloud reached the calvus stage before producing heavy rain."),
    ("CAPILLATUS", "Cumulonimbus cloud top featuring fibrous cirrus structure", "A capillatus storm cloud top displayed dense fibrous ice filaments."),
    ("INCUS", "Anvil-shaped top of a fully developed cumulonimbus storm", "The incus cloud spread wide at the tropopause boundary."),
    ("SPISSATUS", "Dense cirrus cloud thick enough to veil or hide the sun", "Cirrus spissatus clouds cast grey shadows across the ground."),
    ("VELUM", "Thin veil-like cloud cap resting above or attached to cumulus", "A delicate velum cloud draped over the growing cumulus cloud."),
    ("PANNUS", "Ragged cloud shreds floating beneath main rain cloud deck", "Dark pannus clouds drifted rapidly under the rainstorm base."),
    ("TUBA", "Columnar cloud funnel descending from cloud base", "Storm spotters reported a tuba cloud descending toward ground."),

    # Winds & Pressure Dynamics
    ("WIND", "Perceptible natural movement of air blowing along ground", "A strong north wind blew fallen leaves down the driveway."),
    ("GUST", "Sudden strong rushing burst of wind air", "A gust of wind blew autumn leaves across the sidewalk."),
    ("SQUALL", "Sudden sharp gust of wind often bringing rain or snow", "A squall hit the sailboat as it crossed the open bay."),
    ("DUSTDEVIL", "Small rotating column of air picking up sand in desert", "A dustdevil swirled across hot desert plains at noon."),
    ("WHIRLWIND", "Column of air rotating rapidly around a vertical axis", "A small whirlwind spun dry leaves into small circles."),
    ("AIRMASS", "Vast body of air with uniform temperature and humidity", "A cold continental airmass pushed south from Canada."),
    ("PRESSURE", "Force exerted by weight of atmosphere air layers", "Rising barometer pressure indicated clearing weather ahead."),
    ("AIRFLOW", "Movement of air masses across geographical regions", "Coastal airflow brought cool sea breezes inland."),
    ("VORTEX", "Mass of whirling fluid or air forming spiral core", "The polar vortex brought arctic freezing air down south."),
    ("STORM", "Violent disturbance of atmosphere with rain, wind, or snow", "The severe storm knocked down electric power lines."),
    ("FRONT", "Boundary separating two contrasting air masses", "A sharp weather front brought thunder and dropping temperatures."),
    ("SUPERCELL", "Severe thunderstorm featuring a deep rotating updraft", "Storm chasers tracked a massive supercell across Oklahoma."),
    ("MICROBURST", "Localized column of sinking air causing damaging wind gusts", "A sudden microburst knocked down tree branches during storm."),
    ("WILDFIRE", "Large destructive fire spreading quickly in dry hot weather", "Dry windy weather accelerated the spread of the wildfire."),
    ("DROUGHT", "Prolonged period of abnormally low rainfall causing water shortage", "Severe drought dried up farming reservoirs across the region."),
    ("BAROMETER", "Instrument measuring atmospheric air pressure changes", "A falling barometer reading signaled approaching stormy weather."),
    ("CYCLONIC", "Rotating counterclockwise around a low pressure center", "Cyclonic winds rotated around the tropical storm eye."),
    ("DEPRESSION", "Region of low atmospheric pressure bringing rain and wind", "A deep weather depression brought rain to coastal areas."),
    ("TROUGH", "Elongated region of low atmospheric pressure on weather map", "A upper-level trough triggered widespread thunderstorm activity."),
    ("FOEHN", "Warm dry wind blowing down leeward side of mountain range", "The alpine foehn wind caused rapid snow melt in valleys."),
    ("SIMOOM", "Hot dry dust-laden wind blowing across desert areas", "A stifling simoom wind raised dust clouds in the desert."),
    ("BORAS", "Cold squally wind blowing down from mountains to coastal sea", "Fierce boras winds swept down the Adriatic coastline."),
    ("PAMPERO", "Cold polar wind blowing across South American pampas", "A sudden pampero wind brought severe thunderstorms to plains."),
    ("HARMATTAN", "Dry dusty trade wind blowing along West African coast", "The winter harmattan wind deposited fine Sahara sand."),
    ("KHAMSIN", "Hot dry dusty south wind blowing in North Africa", "The spring khamsin wind raised desert dust storms."),
    ("SHAMAL", "Hot dry northwesterly wind blowing across Persian Gulf", "Summer shamal winds triggered severe dust storms."),
    ("WILLIWAW", "Sudden violent cold wind rushing down coastal mountains", "A sudden williwaw gust battered ships anchored in the fjord."),
    ("OCCLUSION", "Stage where cold front overtakes warm front lifting warm air", "Storm occlusion brought heavy rain and shifting winds."),
    ("OUTFLOW", "Air flowing outward from thunderstorm downdrafts", "Cold storm outflow cooled the hot summer afternoon air."),
    ("INFLOW", "Air feeding inward into thunderstorm rising updrafts", "Warm moist inflow fed energy into the growing supercell."),
    ("ENTRAINMENT", "Mixing of environmental air into rising storm cloud updraft", "Dry air entrainment weakened the storm cloud top."),
    ("GEOSTROPHY", "State of balance between pressure gradient and Coriolis force", "Upper atmospheric geostrophy governs long-range wind currents."),
    ("HELICITY", "Measure of wind shear and rotation potential in storm updrafts", "High atmospheric helicity favored tornado formation."),
    ("VORTICITY", "Measure of local spinning motion in atmospheric air flow", "Positive vorticity aloft fueled storm cloud development."),
    ("TURBULENCE", "Irregular chaotic movement of air currents affecting aircraft", "The airplane encountered moderate turbulence inside clouds."),
    ("CONVERGENCE", "Atmospheric process where air flows inward toward a point", "Low level wind convergence triggered storm cloud formation."),
    ("DIVERGENCE", "Atmospheric process where air flows outward from a region", "Upper level air divergence sustained strong thunderstorm updrafts."),
    ("DIFFUSION", "Spreading or mixing of atmospheric gas molecules", "Gas diffusion mixed volcanic ash throughout upper air layers."),

    # Thermal Physics & Climate
    ("HEAT", "Quality of being hot or high atmospheric temperature", "Midday heat shimmered over asphalt parking lots."),
    ("COLD", "Low temperature or lack of atmospheric warmth", "Bitter cold air frosted outdoor water pipes overnight."),
    ("TEMPERATURE", "Degree of hotness or coldness measured by thermometer", "The daily temperature reached seventy degrees in afternoon."),
    ("CELSIUS", "Centigrade temperature scale where water freezes at zero", "Water freezes at zero degrees Celsius under standard pressure."),
    ("FAHRENHEIT", "Temperature scale where water freezes at thirty-two degrees", "Summer heat reached eighty-five degrees Fahrenheit."),
    ("HEATWAVE", "Extended period of abnormally hot summer weather", "During the heatwave city parks installed cooling water misters."),
    ("COLDSPELL", "Brief period of unusually cold winter weather", "A sudden coldspell froze shallow garden pond surfaces."),
    ("THAW", "Period of warmer weather melting ice and snow", "Spring thaw melted mountain snowpack filling rivers."),
    ("MELT", "Turn from solid ice into liquid water by heat", "Spring sunshine caused rooftop snow to melt rapidly."),
    ("CLIMATE", "Long-term average weather pattern of a region", "The Mediterranean climate features warm dry summers and mild winters."),
    ("CHILL", "Unpleasant cold sensation in air", "An evening chill made us reach for warm blankets."),
    ("FROSTBITE", "Injury to body tissues caused by exposure to extreme cold", "Warm gloves protected hands against severe frostbite."),
    ("HYPOTHERMIA", "Dangerous drop in body temperature from cold exposure", "Hikers wore insulated gear to prevent winter hypothermia."),
    ("SHIVER", "Tremble or shake slightly from cold temperature", "The cold wind made us shiver on the bench."),
    ("SWELTER", "Suffer from oppressive summer heat", "People swelter in non-airconditioned rooms during heatwaves."),
    ("FIERY", "Intensely hot or bright red like glowing sun", "A fiery red sunset colored western horizon clouds."),
    ("HEATINDEX", "Measure combining air temperature and relative humidity", "High heatindex made ninety degrees feel like one hundred."),
    ("WINDCHILL", "Apparent temperature felt by skin due to wind flow", "Strong winter gusts lowered the windchill down to zero."),
    ("INSOLATION", "Amount of solar radiation reaching Earth surface", "Maximum solar insolation occurred at solar noon under clear skies."),
    ("CONVECTION", "Heat transfer by vertical circulation of air currents", "Strong convection created towering thunderstorm clouds by afternoon."),
    ("ADVECTION", "Horizontal transfer of heat or moisture by wind", "Moist sea advection caused thick fog over coastal shores."),
    ("SUBSIDENCE", "Sinking of air mass causing warming and clearing sky", "Atmospheric subsidence under high pressure kept weather sunny."),
    ("BAROCLINICITY", "Measure of temperature gradient along constant pressure surface", "High atmospheric baroclinicities sparked mid-latitude winter storms."),
    ("BAROTROPY", "Atmospheric state where air density depends only on pressure", "Tropical atmosphere exhibits near barotropy during calm periods."),
    ("RADIATION", "Emission of heat or light energy through atmosphere", "Infrared radiation cools the ground on clear nights."),

    # Meteorological Instruments & Optics
    ("WEATHER", "State of atmosphere at a specific place and time", "Mild spring weather brought families outside into community parks."),
    ("GAUGE", "Instrument measuring amount of rain or snow fall", "The rain gauge recorded two inches of rainfall after storm."),
    ("CHART", "Weather map displaying meteorological data and forecasts", "Meteorologists studied the pressure chart to predict rain."),
    ("MIRAGE", "Optical illusion caused by atmospheric light refraction over heat", "Hot desert roads produced a shimmering water mirage illusion."),
    ("CORONA", "Bright disc or ring of light around sun or moon", "A colorful corona surrounded the moon through thin mist."),
    ("GLORY", "Optical phenomenon showing rainbow ring around observer shadow on cloud", "Pilots saw a colorful glory ring around their plane shadow on clouds."),
    ("SUNDOG", "Bright spot of light on either side of sun caused by ice crystals", "Pair of bright sundog spots appeared beside the winter sun."),
    ("SKYBEAM", "Beam of sunlight breaking through cloud gaps", "A single skybeam illuminated the mountain peak."),
    ("SOLAR", "Relating to or derived from light and energy of sun", "Solar panels absorbed bright sunlight on the roof."),
    ("BAROMETRIC", "Relating to atmospheric pressure measurements", "A sudden barometric pressure drop alerted sailors of storm."),
    ("DOPPLER", "Radar tracking speed and direction of precipitation movement", "Doppler radar showed rotating storm clouds near town."),
    ("PROBE", "Sensor instrument sent into atmosphere to gather data", "The weather probe measured humidity inside storm clouds."),
    ("RADIOSONDE", "Instrument package carried by weather balloon to transmit air data", "A radiosonde measured high altitude temperature and pressure."),
    ("STATION", "Local facility measuring regional temperature, rain, and wind", "The automatic weather station updated air pressure readings hourly."),
    ("RADARSITE", "Facility housing radar equipment for weather monitoring", "The coastal radarsite tracked rain bands far offshore."),
    ("WINDMILL", "Structure driven by wind power to pump water or grind grain", "Historic wooden windmills turned gracefully in steady country breeze."),
    ("SYNOPTIC", "Relating to broad regional view of weather systems", "Synoptic maps showed nationwide high and low pressure fronts."),
    ("CELESTIAL", "Relating to sky or outer space visible from Earth", "Stargazers appreciated clear celestial views away from city light."),
    ("PROGNOSIS", "Forecast of future atmospheric weather conditions", "The meteorologist delivered a favorable weekend prognosis."),
    ("SOUNDING", "Measurement of atmospheric variables along vertical profile", "A radiosonde balloon sounding recorded dew point aloft."),
    ("RAWINSONDE", "Radio-tracked balloon measuring wind speed and direction aloft", "National weather stations launched rawinsonde balloons at dawn."),
    ("NEPHOLOGY", "Branch of meteorology dealing with cloud study", "Nephology research categorized cloud ice crystal formation."),

    # Extra Optics, Space Weather & Scales
    ("ELNINO", "Pacific ocean warming climate pattern shifting global weather", "ElNino weather brought heavy winter rainfall to the coast."),
    ("LANINA", "Pacific ocean cooling climate pattern affecting global rainfall", "LaNina weather favored active northern hurricane seasons."),
    ("PERLUCIDUS", "Cloud variety featuring small gaps allowing sun or moon to show", "Altocumulus perlucidus clouds allowed moonlight to filter through."),
    ("TRANSLUCIDUS", "Translucent cloud layer thin enough to reveal position of sun", "Stratus translucidus cloud decks dimmed afternoon sunlight."),
    ("DUPLICATUS", "Superposed cloud layers appearing at different atmospheric levels", "Cirrus duplicatus layers appeared stacked across evening skies."),
    ("LACUNOSUS", "Cloud layer featuring clear rounded holes resembling honeycomb", "Cirrocumulus lacunosus clouds displayed distinct honeycomb patterns."),
    ("RADIATUS", "Parallel cloud bands extending toward horizon due to perspective", "Cirrus radiatus bands stretched straight across western skies."),
    ("FIBRATUS", "Wispy cloud filaments lacking distinct hooks or tufts", "Cirrus fibratus filaments drifted slowly in high winds."),
    ("FLOCCUS", "Small tufted clouds resembling cotton wool flakes", "Altocumulus floccus clouds formed small white tufts overhead."),
    ("NEBULOSUS", "Structureless veil of cloud giving uniform hazy appearance", "Cirrostratus nebulosus cloud layers veiled the sun smoothly."),
    ("OPACUS", "Thick cloud sheet dense enough to completely mask sun or moon", "Stratus opacus clouds blocked all direct daylight."),
    ("STATIONARY", "Weather front or storm remaining motionless over an area", "A stationary front brought three days of continuous light rain."),
    ("RECIRCULATION", "Re-entry of air mass into a geographical region", "Coastal air recirculation trapped urban ozone in the basin."),
    ("DETRAINMENT", "Loss of cloud mass as air exits rising storm updraft", "Anvil detrainment spread cirrus cloud ice across miles."),
    ("ENSO", "El Nino Southern Oscillation climate cycle in Pacific Ocean", "The ENSO climate index forecasts global precipitation anomalies."),
    ("TELECONNECTION", "Climate link between weather anomalies in distant world regions", "Atmospheric teleconnection linked Pacific ocean temp to European winter."),
    ("HADLEY", "Tropical atmospheric circulation cell driving trade winds", "The Hadley cell circulates warm air from equator toward sub-tropics."),
    ("FERREL", "Mid-latitude atmospheric circulation cell driving prevailing westerlies", "The Ferrel cell governs temperate weather storm tracks."),
    ("WALKER", "Equatorial Pacific ocean air circulation cell across basin", "The Walker circulation strengthens during La Nina climate events."),
    ("POLARVORTEX", "Persistent large-scale low-pressure cyclone at Earth poles", "A split polarvortex sent frigid arctic air southward."),
    ("MACROBURST", "Large downburst of sinking cold air spanning over two miles", "The macroburst damaged farm structures across the county."),
    ("PYROCUMULUS", "Cumulus cloud produced by intense heat from wildfire or volcano", "A massive pyrocumulus cloud towered above the forest fire."),
    ("DISTRAIL", "Dissipation trail or clear linear gap cut through a cloud deck", "An airplane created a long distrail gap in the stratus layer."),
    ("FALLSTREAK", "Ice crystal trail falling from cloud evaporating before ground", "Delicate fallstreak hole clouds formed in high altocumulus."),
    ("MESOSCALE", "Weather system scale ranging from several to hundreds of miles", "Mesoscale convective complexes bring heavy nocturnal rainstorms."),
    ("MICROSCALE", "Smallest weather phenomenon scale such as thermals and gusts", "Microscale turbulence affected wind turbine efficiency on the ridge."),
    ("PLANETARY", "Global scale atmospheric wind circulation spanning continents", "Planetary waves govern jet stream meanders across hemispheres."),
    ("ROSSBY", "Meandering planetary atmospheric wave in jet stream flow", "Rossby waves created alternating heatwaves and cold snaps."),
    ("GRAVITYWAVE", "Atmospheric wave created by buoyancy and gravity forces", "Mountain gravitywave cloud patterns rippled across the desert."),
    ("SHEAR", "Change in wind speed or direction over vertical distance", "Strong vertical wind shear favored tornado-producing supercells."),
    ("SUPERCOOLED", "Water remaining liquid below standard freezing point", "Supercooled water droplets froze instantly upon striking aircraft wings."),
    ("EMISSIVITY", "Effectiveness of Earth surface in emitting thermal radiation", "Snow covers exhibit high thermal emissivity during clear nights."),
    ("ABSORPTIVITY", "Fraction of solar radiation absorbed by atmospheric gases", "Ozone absorptivity filters harmful solar ultraviolet radiation."),
    ("REFLECTIVITY", "Intensity of radar signal reflected back by precipitation", "High radar reflectivity indicated heavy rainfall in storm cores."),
    ("ATTENUATION", "Reduction of radar signal strength passing through rain clouds", "Heavy hail caused radar beam attenuation behind the storm core."),
    ("OBSCURATION", "Atmospheric phenomenon reducing horizontal visibility near ground", "Dense fog created severe flight obscuration at the airport."),
    ("SMOKE", "Fine suspension of solid carbon particles in atmospheric air", "Wildfire smoke dimmed afternoon sunlight into a deep orange."),
    ("IRIDESCENCE", "Brilliant rainbow colors displayed along edges of thin clouds", "Diffraction produced vivid cloud iridescence near sunset."),
    ("OPALESCENCE", "Pearly milky light scattering phenomenon in cloud ice droplets", "High cirrus clouds displayed delicate opalescence in winter sun."),
    ("LIGHTNINGROD", "Grounded metal rod mounted on building to divert lightning", "The high copper lightningrod protected the church steeple."),
    ("THUNDERHEAD", "Cumulonimbus storm cloud building high into atmosphere", "A massive thunderhead towered on the western horizon."),
    ("AEROSOL", "Suspension of fine solid particles or liquid droplets in air", "Volcanic aerosols reflect solar radiation back into space."),
    ("PARTICULATE", "Tiny discrete mass of solid or liquid matter suspended in gas", "Particulate matter in smog reduces atmospheric visibility."),
    ("PARHELION", "Bright spot appearing on optical halo on either side of sun", "Ice crystal refraction created a stunning parhelion mock sun."),
    ("PARASELENE", "Bright spot appearing on optical halo beside the moon", "A rare paraselene moondog lit up the cold winter night sky."),
    ("BROCKEN", "Optical phenomenon where shadow of observer is cast onto cloud", "Hikers witnessed the Brocken spectre shadow encircled by rainbow rings."),
    ("BEAUFORT", "Empirical scale relating wind speed to observed conditions", "Beaufort scale gale force winds whipped coastal waters."),
    ("FUJITA", "Scale rating tornado intensity based on structural damage", "The tornado was rated EF3 on the enhanced Fujita scale."),
    ("SAFFIR", "Scale rating hurricane intensity from category one to five", "Category four winds were measured on the Saffir hurricane scale."),
    ("DEWPOINT", "Temperature to which air must cool to become saturated", "High dewpoint values made the evening air feel extremely sticky."),
    ("HEATBURST", "Rare atmospheric event causing sudden temp rise and gale winds", "A midnight heatburst raised temperatures unexpectedly."),
    ("DOWNBURST", "Strong ground-level wind system emanating from storm source", "The damaging downburst flattened corn fields."),
    ("GUSTNADO", "Short-lived weak whirlwind forming along a gust front", "A small gustnado kicked up dust along the leading storm edge."),
    ("LANDSPOUT", "Tornado originating from non-supercell thunderstorm cloud", "A landspout formed over dry prairie fields."),
    ("AIRBORNE", "Carried or transported through atmospheric air currents", "Pollen and dust particles remained airborne for miles."),
    ("BUOYANCY", "Upward force exerted on warm rising air packets", "Thermal buoyancy caused the hot air balloon to ascend."),
    ("RETROGRESSION", "Westward movement of atmospheric waves against normal flow", "Wave retrogression altered regional storm tracks."),
    ("SEASONAL", "Occurring at or dependent on a particular season", "Seasonal rains filled dry riverbeds in spring."),
    ("PERIODIC", "Occurring at regular intervals like weather cycles", "Periodic ocean currents influenced regional rainfall patterns."),
    ("DAILY", "Occurring every day like day and night temperature shifts", "Daily temperature changes were mild along the coast."),
    ("DIURNAL", "Occurring during daytime hours or daily cycle", "Diurnal heating caused afternoon cloud build-up over mountains."),
    ("NOCTURNAL", "Occurring during night hours", "Nocturnal cooling lowered air temperatures before sunrise."),
    ("ZENITH", "Highest point reached by sun in sky directly overhead", "Midday sun reached its zenith over tropical regions."),
    ("ECLIPSE", "Obscuring of light from one celestial body by another", "A solar eclipse cast brief twilight shadows over the land.")
]

# Strict deduplication & family capping (Max 1 per suffix family)
suffix_blacklist_families = ['TIME', 'WEATHER', 'DAY', 'NIGHT', 'WIND', 'AIR', 'RAIN', 'SNOW', 'CLOUD', 'STORM', 'METEOR', 'SPHERE', 'METER', 'GRAPH', 'CLIMATE', 'GRAM', 'SCOPE', 'GENESIS', 'FALL', 'FLOOD', 'BURST', 'FRONT', 'SPOT', 'HAZARD', 'ADVISORY', 'WARNING', 'ALERT', 'SEASON']
family_counts = {}
words_set = set()
root_set = set()
clean_ch22 = []

def get_base_root(word):
    w = word.upper()
    for suffix in ['ATION', 'ATING', 'ATIVE', 'ICAL', 'ALLY', 'LESS', 'NESS', 'MENT', 'ING', 'ED', 'ER', 'EST', 'ITY', 'IC', 'AL', 'IVE']:
        if len(w) > len(suffix) + 3 and w.endswith(suffix):
            return w[:-len(suffix)]
    return w

def get_family_tag(word):
    w = word.upper()
    for fam in suffix_blacklist_families:
        if w.endswith(fam) and len(w) > len(fam) + 2:
            return fam
    return None

for word, definition, example in raw_weather_words:
    w = word.upper().strip().replace("-", "").replace(" ", "")
    
    # 1. Skip if used in prior chapters 1-21
    if w in used_words:
        continue
    
    # 2. Skip if already in words_set
    if w in words_set:
        continue
    
    # 3. Skip plural pairs
    if w.endswith('S') and w[:-1] in words_set:
        continue
        
    # 4. Limit suffix family repetition to max 1
    fam = get_family_tag(w)
    if fam:
        if family_counts.get(fam, 0) >= 1:
            print(f"Skipping suffix family repeat ({fam}): {w}")
            continue
        family_counts[fam] = family_counts.get(fam, 0) + 1

    # 5. Enforce root uniqueness for inflectional variants
    base = get_base_root(w)
    if base in root_set and len(base) >= 4:
        print(f"Skipping inflectional variant: {w} (base root {base} already used)")
        continue
        
    words_set.add(w)
    root_set.add(base)
    clean_ch22.append({
        "word": w,
        "definition": definition,
        "example": example
    })

print(f"Total raw words prepared: {len(raw_weather_words)}")
print(f"Total valid unique Ch22 words before shuffle: {len(clean_ch22)}")

# Shuffle randomly so words are not grouped by type per user request
random.seed(42)
random.shuffle(clean_ch22)

if len(clean_ch22) >= 364:
    with open("scratch/chapter_22_clean_words.json", "w", encoding="utf-8") as f:
        json.dump(clean_ch22, f, indent=2)
    print(f"SUCCESS: {len(clean_ch22)} 100% unique words randomly shuffled & saved in scratch/chapter_22_clean_words.json!")
else:
    print(f"STILL NEED {364 - len(clean_ch22)} MORE WORDS!")
