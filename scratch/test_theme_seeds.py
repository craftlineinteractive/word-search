import json
from nltk.corpus import wordnet as wn
from nltk.stem import PorterStemmer

ps = PorterStemmer()

theme_seeds = {
    "food": ['food.n.01', 'food.n.02', 'dish.n.02', 'beverage.n.01', 'produce.n.01', 'fruit.n.01', 'vegetable.n.01', 'nut.n.01', 'herb.n.01', 'spice.n.01', 'baked_good.n.01', 'dairy_product.n.01', 'meat.n.01', 'seafood.n.01', 'condiment.n.01', 'sweet.n.01', 'dessert.n.01'],
    "holiday": ['holiday.n.01', 'holiday.n.02', 'vacation.n.01', 'celebration.n.01', 'festival.n.01', 'leisure.n.01', 'recreation.n.01', 'tour.n.01', 'ceremony.n.01', 'party.n.04', 'season.n.02', 'feast.n.01', 'tradition.n.01', 'gift.n.01', 'parade.n.01'],
    "jobs": ['profession.n.01', 'occupation.n.01', 'craftsman.n.01', 'worker.n.01', 'specialist.n.01', 'trader.n.01', 'medical_practitioner.n.01', 'educator.n.01', 'scientist.n.01', 'officer.n.01', 'engineer.n.01', 'artisan.n.01', 'mechanic.n.01', 'technician.n.01'],
    "electronics": ['electronics.n.01', 'electronic_device.n.01', 'circuit.n.01', 'computer.n.01', 'hardware.n.03', 'component.n.03', 'semiconductor.n.01', 'diode.n.01', 'sensor.n.01', 'display.n.06', 'amplifier.n.01', 'transistor.n.01', 'cable.n.01', 'microprocessor.n.01', 'battery.n.02'],
    "books": ['book.n.01', 'publication.n.01', 'literature.n.01', 'novel.n.01', 'poem.n.01', 'author.n.01', 'library.n.01', 'manuscript.n.01', 'prose.n.01', 'verse.n.01', 'narrative.n.01', 'text.n.01', 'volume.n.01', 'edition.n.01', 'biography.n.01'],
    "games": ['game.n.01', 'game.n.03', 'board_game.n.01', 'card_game.n.01', 'puzzle.n.01', 'toy.n.01', 'play.n.08', 'chess.n.02', 'domino.n.03', 'strategy.n.02', 'dice.n.01', 'quest.n.02'],
    "plants": ['plant.n.02', 'tree.n.01', 'flower.n.01', 'shrub.n.01', 'herb.n.02', 'fern.n.01', 'foliage.n.01', 'seed.n.01', 'botany.n.02', 'bark.n.01', 'root.n.01', 'leaf.n.01', 'bloom.n.01', 'flora.n.01', 'conifer.n.01', 'evergreen.n.01'],
    "painting": ['painting.n.01', 'painting.n.02', 'drawing.n.01', 'pigment.n.01', 'color.n.01', 'canvas.n.01', 'brush.n.02', 'easel.n.01', 'art.n.01', 'portrait.n.01', 'landscape.n.03', 'watercolor.n.01', 'sculpture.n.01', 'gallery.n.03', 'artist.n.01', 'fresco.n.01'],
    "words": ['language.n.01', 'linguistics.n.01', 'grammar.n.01', 'speech.n.02', 'syntax.n.01', 'rhetoric.n.01', 'word.n.01', 'syllable.n.01', 'vowel.n.01', 'consonant.n.01', 'dictionary.n.01', 'phrase.n.01', 'accent.n.01'],
    "professional": ['commerce.n.01', 'business.n.01', 'management.n.01', 'finance.n.01', 'law.n.01', 'accounting.n.01', 'corporation.n.01', 'executive.n.01', 'contract.n.01', 'investment.n.01', 'capital.n.01', 'market.n.01', 'strategy.n.01', 'audit.n.01'],
    "religion": ['religion.n.01', 'faith.n.02', 'worship.n.01', 'temple.n.01', 'church.n.02', 'prayer.n.01', 'ritual.n.01', 'theology.n.01', 'sacrament.n.01', 'scripture.n.01', 'virtue.n.01', 'clergyman.n.01', 'monk.n.01', 'deity.n.01', 'pilgrimage.n.01'],
    "music": ['music.n.01', 'musical_instrument.n.01', 'melody.n.01', 'harmony.n.02', 'rhythm.n.01', 'song.n.01', 'orchestra.n.01', 'tempo.n.01', 'scale.n.06', 'chord.n.01', 'tune.n.01', 'singer.n.01', 'musician.n.01', 'opera.n.01'],
    "hobby": ['hobby.n.01', 'pastime.n.01', 'craft.n.01', 'sewing.n.01', 'gardening.n.01', 'collecting.n.01', 'woodworking.n.01', 'pottery.n.01', 'knitting.n.01', 'weaving.n.01', 'astronomy.n.01', 'stamp.n.01'],
    "nature": ['nature.n.03', 'landform.n.01', 'mountain.n.01', 'valley.n.01', 'river.n.01', 'forest.n.01', 'wilderness.n.01', 'geology.n.01', 'landscape.n.01', 'desert.n.01', 'glacier.n.01', 'canyon.n.01', 'island.n.01', 'biome.n.01'],
    "tournament": ['tournament.n.01', 'contest.n.01', 'competition.n.01', 'match.n.02', 'championship.n.01', 'trophy.n.01', 'medal.n.01', 'victory.n.01', 'athlete.n.01', 'stadium.n.01', 'score.n.03', 'referee.n.01', 'champion.n.01'],
    "education": ['education.n.01', 'school.n.01', 'university.n.01', 'student.n.01', 'teacher.n.01', 'course.n.01', 'study.n.02', 'curriculum.n.01', 'discipline.n.01', 'academy.n.03', 'degree.n.01', 'lecture.n.01', 'science.n.01', 'knowledge.n.01'],
    "technology": ['technology.n.01', 'computing.n.01', 'software.n.01', 'telecommunication.n.01', 'automation.n.01', 'robotics.n.01', 'algorithm.n.01', 'network.n.05', 'database.n.01', 'internet.n.01', 'innovation.n.01', 'engineering.n.02'],
    "birds": ['bird.n.01', 'passerine.n.01', 'raptor.n.01', 'waterfowl.n.01', 'seabird.n.01', 'parrot.n.01', 'owl.n.01', 'feather.n.01', 'wing.n.01', 'beak.n.01', 'nest.n.01', 'plumage.n.01'],
    "weather": ['weather.n.01', 'precipitation.n.01', 'cloud.n.01', 'wind.n.01', 'storm.n.01', 'atmosphere.n.01', 'meteorology.n.01', 'temperature.n.01', 'rain.n.01', 'snow.n.01', 'breeze.n.01', 'thunder.n.01', 'climate.n.01'],
    "ocean": ['ocean.n.01', 'sea.n.01', 'marine_animal.n.01', 'fish.n.01', 'water.n.01', 'tide.n.01', 'wave.n.01', 'coral.n.01', 'coast.n.01', 'reef.n.01', 'current.n.02', 'abyss.n.01', 'coastline.n.01'],
    "sports": ['sport.n.01', 'athletics.n.01', 'athletic_game.n.01', 'gymnastics.n.01', 'racing.n.01', 'ball.n.01', 'exercise.n.01', 'swimming.n.01', 'football.n.01', 'tennis.n.01', 'boxing.n.01', 'cycling.n.01'],
    "pets": ['pet.n.01', 'domestic_animal.n.01', 'dog.n.01', 'cat.n.01', 'puppy.n.01', 'kitten.n.01', 'rodent.n.01', 'rabbit.n.01', 'aquarium.n.01', 'kennel.n.01', 'leash.n.01'],
    "vehicles": ['vehicle.n.01', 'wheeled_vehicle.n.01', 'motor_vehicle.n.01', 'car.n.01', 'truck.n.01', 'train.n.01', 'aircraft.n.01', 'vessel.n.02', 'boat.n.01', 'ship.n.01', 'engine.n.01', 'wheel.n.01'],
    "city": ['city.n.01', 'municipality.n.01', 'urban_area.n.01', 'building.n.01', 'street.n.01', 'road.n.01', 'avenue.n.01', 'plaza.n.01', 'neighborhood.n.02', 'skyscraper.n.01', 'transit.n.02'],
    "home": ['home.n.01', 'house.n.01', 'dwelling.n.01', 'room.n.01', 'furniture.n.01', 'household.n.01', 'kitchen.n.01', 'bedroom.n.01', 'appliance.n.01', 'decor.n.01', 'yard.n.01'],
    "wild-animals": ['animal.n.01', 'mammal.n.01', 'carnivore.n.01', 'herbivore.n.01', 'reptile.n.01', 'amphibian.n.01', 'wildlife.n.01', 'beast.n.01', 'predator.n.02', 'fauna.n.01', 'safari.n.01'],
    "fashion": ['fashion.n.03', 'clothing.n.01', 'garment.n.01', 'footwear.n.01', 'textile.n.01', 'fabric.n.01', 'attire.n.01', 'costume.n.01', 'accessory.n.02', 'dress.n.01', 'suit.n.01'],
    "entertainment": ['entertainment.n.01', 'show.n.01', 'performance.n.02', 'theater.n.01', 'cinema.n.01', 'circus.n.01', 'comedy.n.01', 'broadcasting.n.01', 'television.n.01', 'amusement.n.01'],
    "adventure": ['adventure.n.01', 'expedition.n.01', 'exploration.n.01', 'voyage.n.01', 'safari.n.01', 'trek.n.01', 'discovery.n.03', 'pioneer.n.01', 'journey.n.01', 'summit.n.02', 'compass.n.01'],
    "fantasy": ['fantasy.n.01', 'mythology.n.01', 'legend.n.01', 'magic.n.01', 'mythical_being.n.01', 'monster.n.01', 'dragon.n.01', 'enchantment.n.01', 'sorcery.n.01', 'folklore.n.01', 'potion.n.01', 'spell.n.01']
}

def get_hypos(syn):
    h_all = set()
    for h in syn.hyponyms():
        h_all.add(h)
        h_all.update(get_hypos(h))
    return h_all

print("Testing hyponym extraction for each theme...")
for key, seeds in theme_seeds.items():
    words = set()
    for s_name in seeds:
        try:
            syn = wn.synset(s_name)
            all_s = get_hypos(syn)
            all_s.add(syn)
            for s in all_s:
                for l in s.lemmas():
                    name = l.name()
                    if '_' not in name and '-' not in name and name.isalpha() and 3 <= len(name) <= 14:
                        words.add(name.upper())
        except Exception as e:
            pass
    print(f"Theme {key:<15}: {len(words)} clean single words")
