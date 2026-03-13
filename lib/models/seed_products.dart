import 'package:uuid/uuid.dart';
import 'models.dart';

List<Product> buildSeedProducts() {
  const u = Uuid();

  // Helper to build product
  Product p(String name, String cat, double price, double? was, int stock,
      String img, String part, String brand, String compat, String desc,
      {bool featured = false}) =>
    Product(
      id:           u.v4(),
      name:         name,
      category:     cat,
      price:        price,
      comparePrice: was,
      stock:        stock,
      imageUrl:     img,
      images:       [img],
      partNumber:   part,
      brand:        brand,
      compatibility:compat,
      description:  desc,
      featured:     featured,
      rating:       3.5 + (price % 1.5),
      reviewCount:  (stock * 3).clamp(4, 120),
    );

  return [
    // ── Engine Parts ─────────────────────────────────────────────
    p('Piston Ring Set - Standard Size',
      'Engine Parts', 85000, 95000, 12,
      'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&q=80',
      'PR-7012-STD', 'Nippon Pistons',
      'Toyota Corolla, Toyota Camry, Yaris',
      'Premium standard-size piston ring set. Fits 1.6L and 1.8L engines. Reduces oil consumption and improves compression.',
      featured: true),

    p('Timing Belt Kit with Water Pump',
      'Engine Parts', 145000, 165000, 8,
      'https://images.unsplash.com/photo-1558981408-db0ecd8a1ee4?w=600&q=80',
      'TB-2040-KIT', 'Gates',
      'Toyota Rav4, Camry, Hilux',
      'Complete timing belt replacement kit including idler, tensioner and water pump. OEM equivalent specification.',
      featured: true),

    p('Engine Oil Sump Pan - Aluminium',
      'Engine Parts', 78000, null, 5,
      'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
      'SP-4400', 'Genuine Parts',
      'Nissan Navara, Nissan Patrol',
      'High-quality aluminium sump pan. Includes drain plug and gasket. Direct bolt-on replacement.'),

    p('Cylinder Head Gasket Set',
      'Engine Parts', 55000, 68000, 15,
      'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=600&q=80',
      'HG-3311', 'Fel-Pro',
      'Toyota, Nissan, Mitsubishi',
      'Multi-layer steel cylinder head gasket. Heat resistant up to 1400°C. Includes all necessary gaskets for a complete head job.'),

    p('Crankshaft Main Bearing Set',
      'Engine Parts', 42000, null, 20,
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80',
      'CB-5520-010', 'King Bearings',
      'Toyota Hilux D4D, Prado',
      '0.10mm undersized main bearing set. Precision-ground to OEM tolerances. Set of 5 shells.'),

    // ── Brakes & Clutch ───────────────────────────────────────────
    p('Disc Brake Pads - Front Axle Set',
      'Brakes & Clutch', 38000, 45000, 30,
      'https://images.unsplash.com/photo-1558981285-6f0c94958bb6?w=600&q=80',
      'BP-4410-F', 'Brembo',
      'Toyota Land Cruiser 200, Prado 150',
      'Semi-metallic front disc brake pads. Low dust, low noise. Includes wear indicators. 4-pad set.',
      featured: true),

    p('Clutch Kit 3-Piece - 230mm',
      'Brakes & Clutch', 195000, 220000, 7,
      'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=600&q=80',
      'CK-230-HQ', 'Sachs',
      'Toyota Hilux, Fortuner, Innova',
      'Complete 3-piece clutch kit: pressure plate, friction disc, and pilot bearing. 230mm diameter.'),

    p('Brake Master Cylinder',
      'Brakes & Clutch', 88000, null, 9,
      'https://images.unsplash.com/photo-1489824904134-891ab64532f1?w=600&q=80',
      'BMC-7701', 'TRW',
      'Nissan Navara D40, Pathfinder',
      'OEM-quality brake master cylinder with integral reservoir. Includes seals and mounting hardware.'),

    p('Rear Brake Drum - Vented',
      'Brakes & Clutch', 52000, 59000, 14,
      'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=600&q=80',
      'BD-R201', 'ATE',
      'Toyota Corolla 2008-2014, Vitz',
      'Cast-iron rear brake drum. Pre-machined and balanced. Fits left or right side.'),

    // ── Suspension & Steering ─────────────────────────────────────
    p('Shock Absorber - Front (pair)',
      'Suspension & Steering', 175000, 200000, 6,
      'https://images.unsplash.com/photo-1570733577524-3a047079e80d?w=600&q=80',
      'SA-F2200', 'KYB',
      'Toyota Land Cruiser 80, 100 Series',
      'Gas-pressurised twin-tube shock absorbers. Improved damping for heavy loads. Sold as a pair.',
      featured: true),

    p('Tie Rod End - Outer Left',
      'Suspension & Steering', 28000, 32000, 25,
      'https://images.unsplash.com/photo-1606577924006-27d39b132ae2?w=600&q=80',
      'TRE-OL-401', 'Moog',
      'Toyota Corolla 2002-2018',
      'Grease-able outer tie rod end with tapered stud. Improves steering precision and reduces wandering.'),

    p('Control Arm Bush Kit - Front',
      'Suspension & Steering', 22000, null, 40,
      'https://images.unsplash.com/photo-1621929747188-0b4dc28498d2?w=600&q=80',
      'CAB-F110', 'Whiteline',
      'Mitsubishi Pajero, L200, Triton',
      'Polyurethane control arm bush kit. Reduces vibration. 8-piece set for front lower and upper arms.'),

    // ── Electrical & Ignition ─────────────────────────────────────
    p('Alternator - 100 Amp Remanufactured',
      'Electrical & Ignition', 135000, 155000, 5,
      'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=600&q=80',
      'ALT-100-R', 'Bosch Reman',
      'Toyota Hilux, Camry, Corolla',
      'Remanufactured to OEM spec 100A alternator. Includes built-in voltage regulator. 12-month warranty.',
      featured: true),

    p('Spark Plugs - Iridium Set of 4',
      'Electrical & Ignition', 32000, 38000, 50,
      'https://images.unsplash.com/photo-1616259833980-afce7f0d3e13?w=600&q=80',
      'SP-IR4-NGK', 'NGK',
      'Most 4-cylinder petrol engines',
      'Long-life iridium tip spark plugs. Improve fuel economy and cold starts. Set of 4.'),

    p('ECU / Engine Control Unit',
      'Electrical & Ignition', 285000, null, 3,
      'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&q=80',
      'ECU-2JZ-8901', 'Denso OEM',
      'Toyota Supra, Crown, Mark II (2JZ)',
      'Original Denso ECU for 2JZ engine. Tested and refurbished. Includes programming service.'),

    p('Car Battery 60Ah / 550CCA',
      'Electrical & Ignition', 98000, 110000, 18,
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
      'BAT-60-MF', 'Varta',
      'Universal fit - most sedans & SUVs',
      'Maintenance-free lead-acid battery. 60Ah capacity. Cold-crank amps 550. Includes terminal adapters.'),

    // ── Filters & Fluids ──────────────────────────────────────────
    p('Engine Oil Filter - Premium',
      'Filters & Fluids', 8500, 10000, 80,
      'https://images.unsplash.com/photo-1594535182308-8ffbfd540e35?w=600&q=80',
      'OF-3001', 'Bosch',
      'Toyota, Nissan, Honda, Mazda',
      'Anti-drain-back valve prevents dry starts. 99.9% filtration efficiency. Replace every 5,000 km.'),

    p('Air Filter - Panel Type',
      'Filters & Fluids', 15000, null, 55,
      'https://images.unsplash.com/photo-1620714223084-8fcacc2dbed6?w=600&q=80',
      'AF-7020', 'K&N',
      'Toyota Hilux 2016-2024',
      'High-flow cotton gauze air filter. Washable and reusable. Up to 10x longer life than paper filters.'),

    p('Engine Oil 5W-30 Semi-Synthetic 4L',
      'Filters & Fluids', 35000, 40000, 100,
      'https://images.unsplash.com/photo-1558980664-769d59546b3d?w=600&q=80',
      'OIL-5W30-4L', 'Castrol',
      'Universal petrol and diesel engines',
      'Castrol EDGE 5W-30 semi-synthetic. API SN/CF certified. Excellent cold-start and high-temperature protection.'),

    p('Cabin Air Filter / Pollen Filter',
      'Filters & Fluids', 12000, 14000, 45,
      'https://images.unsplash.com/photo-1606577924006-27d39b132ae2?w=600&q=80',
      'CAF-220', 'Mann-Filter',
      'Toyota Corolla, Camry, Yaris 2010-2023',
      'Activated carbon cabin filter. Blocks pollen, dust, bacteria and odours. Improves A/C efficiency.'),

    // ── Cooling System ────────────────────────────────────────────
    p('Radiator - Aluminium Core',
      'Cooling System', 225000, 255000, 4,
      'https://images.unsplash.com/photo-1558981408-db0ecd8a1ee4?w=600&q=80',
      'RAD-4400', 'Denso',
      'Toyota Prado 150 2010-2020',
      '3-row aluminium core radiator. 30% better heat dissipation than stock. Direct bolt-on with all tanks.',
      featured: true),

    p('Thermostat + Housing Kit',
      'Cooling System', 24000, 29000, 30,
      'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=600&q=80',
      'TH-1101-KIT', 'Gates',
      'Toyota 1GR-FE, 2GR-FE engines',
      'OEM-spec thermostat with housing and gasket. Opens at 82°C for optimum operating temperature.'),

    p('Radiator Hose Upper + Lower Set',
      'Cooling System', 18000, null, 22,
      'https://images.unsplash.com/photo-1555248048-d8f12498b36e?w=600&q=80',
      'RH-SET-302', 'Dayco',
      'Nissan Patrol Y61, Y60',
      'High-temperature silicone radiator hoses (blue). Rated to 180°C. Includes clamps. Will not crack or harden.'),

    // ── Body Parts ────────────────────────────────────────────────
    p('Front Bumper Assembly - Primed',
      'Body Parts', 185000, 210000, 3,
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=600&q=80',
      'FBP-201-P', 'OEM Replica',
      'Toyota Hilux Revo 2016-2020',
      'High-density polyurethane front bumper. Includes fog light holes and tow hook slots. Ready for paint.'),

    p('Wing Mirror - Left Side Complete',
      'Body Parts', 68000, 75000, 10,
      'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=600&q=80',
      'WM-L-4400', 'Genuine Parts',
      'Toyota Corolla 2019-2023',
      'Electric fold and adjust wing mirror. Heated glass. Includes indicator. OEM quality glass.'),

    p('Bonnet / Hood - Steel',
      'Body Parts', 320000, null, 2,
      'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=600&q=80',
      'BNT-204-ST', 'OEM Replica',
      'Mitsubishi L200 2016-2022',
      'Steel pressed bonnet. Includes hinges and bonnet prop. Prime and paint ready.'),

    // ── Transmission ──────────────────────────────────────────────
    p('Gearbox Oil ATF D-III 4L',
      'Transmission', 42000, 48000, 25,
      'https://images.unsplash.com/photo-1558981285-6f0c94958bb6?w=600&q=80',
      'ATF-DIII-4L', 'Toyota Genuine',
      'Toyota automatic transmissions',
      'Toyota genuine Dexron III ATF. Red-coloured fluid. Change every 40,000 km for gearbox longevity.'),

    p('Transfer Case - Low Range Actuator',
      'Transmission', 115000, 128000, 6,
      'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=600&q=80',
      'TCA-4100', 'Genuine Parts',
      'Toyota Land Cruiser 200, Prado 150',
      'Electric actuator for 4WD low range engagement. Direct plug-and-play replacement. Includes mounting bolts.'),

    // ── Tyres & Wheels ────────────────────────────────────────────
    p('Alloy Wheel 17" x 7J - Single',
      'Tyres & Wheels', 145000, 165000, 8,
      'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=600&q=80',
      'AW-17-7J', 'Lenso',
      'Toyota Fortuner, Hilux 2015+',
      '17 inch 7J alloy wheel in gunmetal finish. 6x139.7 PCD. ET30 offset. Load rated 1000kg.'),

    p('Tyre 265/70R17 - All-Terrain',
      'Tyres & Wheels', 185000, null, 20,
      'https://images.unsplash.com/photo-1527095398449-a5e7636b3c9f?w=600&q=80',
      'TYR-265-70-R17', 'BF Goodrich',
      'Toyota Hilux, Fortuner, Land Cruiser',
      'BF Goodrich All-Terrain T/A KO2 265/70R17. Excellent on road and off road. Load index 121/118S.',
      featured: true),

    // ── Accessories ───────────────────────────────────────────────
    p('Tow Bar - Heavy Duty',
      'Accessories', 275000, null, 5,
      'https://images.unsplash.com/photo-1558981408-db0ecd8a1ee4?w=600&q=80',
      'TB-HD-401', 'ARB',
      'Toyota Hilux Revo, Rocco 2016+',
      'Class III heavy-duty tow bar. Rated 3,500 kg towing capacity. Includes 7-pin trailer wiring harness.'),

    p('Roof Rack - Aluminium Flat',
      'Accessories', 220000, 250000, 7,
      'https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=600&q=80',
      'RR-ALU-200', 'Rhino-Rack',
      'Toyota Land Cruiser 200 Series',
      'Lightweight aluminium flat-rack. 160kg load rating. Includes mount brackets and anti-rattle locks.'),

    p('Dash Cam 4K with Night Vision',
      'Accessories', 95000, 110000, 15,
      'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=600&q=80',
      'DC-4K-NV', 'Viofo',
      'Universal fit - all vehicles',
      'Viofo A119 Mini 2 4K dash cam. Sony STARVIS sensor for night vision. 140° wide angle. Loop recording. GPS.'),
  ];
}
