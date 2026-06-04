class AdobeAppItem {
  final String slug;
  final String name;
  final String svgPath;
  final String descriptionKey;

  const AdobeAppItem({
    required this.slug,
    required this.name,
    required this.svgPath,
    required this.descriptionKey,
  });
}

class AdobeAppRegistry {
  static const List<AdobeAppItem> featuredApps = [
    AdobeAppItem(
      slug: 'photoshop',
      name: 'Photoshop',
      svgPath: 'assets/Icons/photoshop.svg',
      descriptionKey: 'photoshopDesc',
    ),
    AdobeAppItem(
      slug: 'illustrator',
      name: 'Illustrator',
      svgPath: 'assets/Icons/illustrator.svg',
      descriptionKey: 'illustratorDesc',
    ),
    AdobeAppItem(
      slug: 'after-effects',
      name: 'After Effects',
      svgPath: 'assets/Icons/aftereffects.svg',
      descriptionKey: 'afterEffectsDesc',
    ),
    AdobeAppItem(
      slug: 'premiere-pro',
      name: 'Premiere Pro',
      svgPath: 'assets/Icons/premiere.svg',
      descriptionKey: 'premiereProDesc',
    ),
    AdobeAppItem(
      slug: 'lightroom',
      name: 'Lightroom',
      svgPath: 'assets/Icons/lightroom.svg',
      descriptionKey: 'lightroomDesc',
    ),
    AdobeAppItem(
      slug: 'indesign',
      name: 'InDesign',
      svgPath: 'assets/Icons/indesign.svg',
      descriptionKey: 'indesignDesc',
    ),
    AdobeAppItem(
      slug: 'audition',
      name: 'Audition',
      svgPath: 'assets/Icons/audition.svg',
      descriptionKey: 'auditionDesc',
    ),
    AdobeAppItem(
      slug: 'davinci-resolve',
      name: 'DaVinci Resolve',
      svgPath: 'assets/Icons/davinci.svg',
      descriptionKey: 'davinciResolveDesc',
    ),
    AdobeAppItem(
      slug: 'fl-studio',
      name: 'FL Studio',
      svgPath: 'assets/Icons/flstudio.svg',
      descriptionKey: 'flStudioDesc',
    ),
  ];
}
