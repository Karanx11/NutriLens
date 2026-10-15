import '../models/product.dart';

/// Compact reference of common food additive codes (EU "E" numbers, which
/// match the INS numbers printed on Indian labels) with a plain-English name,
/// purpose and a concern level used for badges and scoring.
///
/// Concern levels are a simple editorial guide, not a regulatory verdict.
class AdditivesDb {
  const AdditivesDb._();

  static const Map<String, (String, String, ConcernLevel)> _db = {
    // Colors
    'e100': ('Curcumin', 'Color', ConcernLevel.none),
    'e101': ('Riboflavin', 'Color', ConcernLevel.none),
    'e102': ('Tartrazine', 'Color', ConcernLevel.high),
    'e104': ('Quinoline yellow', 'Color', ConcernLevel.high),
    'e110': ('Sunset yellow', 'Color', ConcernLevel.high),
    'e120': ('Carmine', 'Color', ConcernLevel.moderate),
    'e122': ('Carmoisine', 'Color', ConcernLevel.high),
    'e124': ('Ponceau 4R', 'Color', ConcernLevel.high),
    'e129': ('Allura red', 'Color', ConcernLevel.high),
    'e132': ('Indigotine', 'Color', ConcernLevel.moderate),
    'e133': ('Brilliant blue', 'Color', ConcernLevel.moderate),
    'e140': ('Chlorophylls', 'Color', ConcernLevel.none),
    'e150a': ('Plain caramel', 'Color', ConcernLevel.none),
    'e150b': ('Caustic sulphite caramel', 'Color', ConcernLevel.low),
    'e150c': ('Ammonia caramel', 'Color', ConcernLevel.moderate),
    'e150d': ('Sulphite ammonia caramel', 'Color', ConcernLevel.high),
    'e160a': ('Carotenes', 'Color', ConcernLevel.none),
    'e160c': ('Paprika extract', 'Color', ConcernLevel.none),
    'e162': ('Beetroot red', 'Color', ConcernLevel.none),
    'e171': ('Titanium dioxide', 'Color', ConcernLevel.high),
    // Preservatives
    'e200': ('Sorbic acid', 'Preservative', ConcernLevel.low),
    'e202': ('Potassium sorbate', 'Preservative', ConcernLevel.low),
    'e211': ('Sodium benzoate', 'Preservative', ConcernLevel.moderate),
    'e220': ('Sulphur dioxide', 'Preservative', ConcernLevel.moderate),
    'e223': ('Sodium metabisulphite', 'Preservative', ConcernLevel.moderate),
    'e250': ('Sodium nitrite', 'Preservative', ConcernLevel.high),
    'e251': ('Sodium nitrate', 'Preservative', ConcernLevel.high),
    // Acids, antioxidants
    'e260': ('Acetic acid', 'Acidity regulator', ConcernLevel.none),
    'e270': ('Lactic acid', 'Acidity regulator', ConcernLevel.none),
    'e296': ('Malic acid', 'Acidity regulator', ConcernLevel.none),
    'e300': ('Ascorbic acid (vitamin C)', 'Antioxidant', ConcernLevel.none),
    'e306': ('Tocopherol-rich extract', 'Antioxidant', ConcernLevel.none),
    'e319': ('TBHQ', 'Antioxidant', ConcernLevel.high),
    'e320': ('BHA', 'Antioxidant', ConcernLevel.high),
    'e321': ('BHT', 'Antioxidant', ConcernLevel.high),
    'e322': ('Lecithins', 'Emulsifier', ConcernLevel.none),
    'e330': ('Citric acid', 'Acidity regulator', ConcernLevel.none),
    'e331': ('Sodium citrates', 'Acidity regulator', ConcernLevel.none),
    'e338': ('Phosphoric acid', 'Acidity regulator', ConcernLevel.moderate),
    'e339': ('Sodium phosphates', 'Stabiliser', ConcernLevel.moderate),
    'e340': ('Potassium phosphates', 'Stabiliser', ConcernLevel.moderate),
    'e341': ('Calcium phosphates', 'Stabiliser', ConcernLevel.low),
    // Thickeners, emulsifiers
    'e407': ('Carrageenan', 'Thickener', ConcernLevel.moderate),
    'e412': ('Guar gum', 'Thickener', ConcernLevel.none),
    'e414': ('Acacia gum', 'Thickener', ConcernLevel.none),
    'e415': ('Xanthan gum', 'Thickener', ConcernLevel.none),
    'e420': ('Sorbitol', 'Sweetener', ConcernLevel.low),
    'e421': ('Mannitol', 'Sweetener', ConcernLevel.low),
    'e422': ('Glycerol', 'Humectant', ConcernLevel.none),
    'e440': ('Pectins', 'Thickener', ConcernLevel.none),
    'e450': ('Diphosphates', 'Raising agent', ConcernLevel.moderate),
    'e451': ('Triphosphates', 'Stabiliser', ConcernLevel.moderate),
    'e452': ('Polyphosphates', 'Stabiliser', ConcernLevel.moderate),
    'e466': ('Carboxymethyl cellulose', 'Thickener', ConcernLevel.low),
    'e471': ('Mono- and diglycerides', 'Emulsifier', ConcernLevel.low),
    'e472e': ('DATEM', 'Emulsifier', ConcernLevel.low),
    'e481': ('Sodium stearoyl lactylate', 'Emulsifier', ConcernLevel.low),
    // Raising agents, minerals
    'e500': ('Sodium carbonates', 'Raising agent', ConcernLevel.none),
    'e501': ('Potassium carbonates', 'Acidity regulator', ConcernLevel.none),
    'e503': ('Ammonium carbonates', 'Raising agent', ConcernLevel.none),
    'e508': ('Potassium chloride', 'Thickener', ConcernLevel.none),
    'e551': ('Silicon dioxide', 'Anti-caking agent', ConcernLevel.none),
    // Flavour enhancers
    'e621': ('Monosodium glutamate (MSG)', 'Flavour enhancer', ConcernLevel.moderate),
    'e627': ('Disodium guanylate', 'Flavour enhancer', ConcernLevel.moderate),
    'e631': ('Disodium inosinate', 'Flavour enhancer', ConcernLevel.moderate),
    'e635': ('Disodium ribonucleotides', 'Flavour enhancer', ConcernLevel.moderate),
    // Sweeteners
    'e950': ('Acesulfame K', 'Sweetener', ConcernLevel.moderate),
    'e951': ('Aspartame', 'Sweetener', ConcernLevel.moderate),
    'e952': ('Cyclamate', 'Sweetener', ConcernLevel.moderate),
    'e954': ('Saccharin', 'Sweetener', ConcernLevel.moderate),
    'e955': ('Sucralose', 'Sweetener', ConcernLevel.low),
    'e960': ('Steviol glycosides', 'Sweetener', ConcernLevel.none),
    'e965': ('Maltitol', 'Sweetener', ConcernLevel.low),
    'e967': ('Xylitol', 'Sweetener', ConcernLevel.low),
  };

  /// Builds an [Additive] from an Open Food Facts tag such as `en:e150d`.
  static Additive fromTag(String tag) {
    final raw = tag.contains(':')
        ? tag.substring(tag.lastIndexOf(':') + 1).trim().toLowerCase()
        : tag.trim().toLowerCase();
    final code = raw.startsWith('e') ? 'E${raw.substring(1)}' : raw.toUpperCase();
    final entry = _db[raw];
    if (entry == null) {
      return Additive(
        code: code,
        name: 'Additive $code',
        purpose: 'Not in local reference',
        concern: ConcernLevel.low,
      );
    }
    return Additive(
      code: code,
      name: entry.$1,
      purpose: entry.$2,
      concern: entry.$3,
    );
  }
}
