class Article {
  final String id;
  final String category;
  final String tag;
  final String title;
  final String summary;
  final String content;
  final String readTime;
  final String imageEmoji;
  final bool isSpotlight;

  const Article({
    required this.id,
    required this.category,
    required this.tag,
    required this.title,
    required this.summary,
    required this.content,
    required this.readTime,
    required this.imageEmoji,
    this.isSpotlight = false,
  });
}

class EducationData {
  static const List<Article> articles = [
    // ── SPOTLIGHT ───────────────────────────────────────────
    Article(
      id: 'h1',
      category: 'Health',
      tag: 'EARLY DEVELOPMENT',
      title: 'Understanding Milestones',
      summary:
          'A comprehensive guide to your child\'s first steps and developmental markers.',
      content: '''
## Understanding Developmental Milestones

Every child grows at their own pace, but developmental milestones give parents and healthcare providers a general idea of the changes to expect as a child gets older.

### Physical Milestones (0–12 months)
- **Birth–3 months**: Lifts head when lying on stomach, follows objects with eyes, smiles at familiar faces
- **4–6 months**: Rolls over, sits with support, reaches for objects
- **7–9 months**: Sits without support, starts crawling, responds to name
- **10–12 months**: Pulls to stand, takes first steps, uses pincer grasp

### Language Milestones
- By 6 months: Babbles and makes consonant sounds (ba, da, ma)
- By 12 months: Says "mama" or "dada" with meaning, understands simple instructions
- By 18 months: Vocabulary of 10–20 words
- By 24 months: Uses 2-word phrases ("more milk", "go out")

### When to Talk to Your Doctor
If your child is not meeting multiple milestones in the same age range, speak with your PHM or paediatrician. Early intervention makes a significant difference.

### Tips for Parents
- Talk, sing, and read to your baby every day
- Provide safe opportunities for physical exploration
- Limit screen time for children under 2
- Make eye contact and respond to your baby's cues
      ''',
      readTime: '5 min read',
      imageEmoji: '👶',
      isSpotlight: true,
    ),

    // ── HEALTH ──────────────────────────────────────────────
    Article(
      id: 'h2',
      category: 'Health',
      tag: 'HEALTH',
      title: 'Common Childhood Illnesses',
      summary:
          'How to recognize and respond to common illnesses in infants and toddlers.',
      content: '''
## Common Childhood Illnesses

Young children get sick frequently as their immune systems develop. Knowing what to look for helps you respond quickly.

### The Common Cold
- **Symptoms**: Runny nose, mild fever, cough, congestion
- **Duration**: 7–10 days
- **Treatment**: Rest, fluids, saline drops for congestion. Avoid giving adult medicines.
- **See a doctor if**: Fever above 38.5°C in infants under 3 months, difficulty breathing, or symptoms last more than 10 days

### Ear Infections
- **Signs**: Tugging at ears, crying more than usual, trouble sleeping, fever
- **Common age**: 6 months to 2 years
- **Treatment**: Often resolves on its own; sometimes antibiotics are needed
- **Prevention**: Breastfeeding reduces risk; avoid smoke exposure

### Fever Management
- Fever is not an illness — it is a sign the immune system is working
- Normal temperature: 36.5–37.5°C
- Give paracetamol (not aspirin) for discomfort
- Keep the child hydrated
- **Seek emergency care if**: Fever above 40°C, seizure, stiff neck, rash, difficulty breathing

### Hand, Foot and Mouth Disease
- **Symptoms**: Sores in mouth, rash on hands and feet, fever
- **Contagious**: Yes — keep child home from daycare
- **Treatment**: Comfort care, fluids, pain relief
      ''',
      readTime: '6 min read',
      imageEmoji: '🤒',
    ),
    Article(
      id: 'h3',
      category: 'Health',
      tag: 'HEALTH',
      title: 'Healthy Sleep Habits',
      summary: 'Building good sleep routines from birth through toddlerhood.',
      content: '''
## Healthy Sleep Habits for Babies and Toddlers

Sleep is critical for brain development, growth, and immune function. Establishing good habits early makes a lasting difference.

### How Much Sleep Does Your Child Need?
- **Newborn (0–3 months)**: 14–17 hours/day
- **Infant (4–11 months)**: 12–15 hours/day
- **Toddler (1–2 years)**: 11–14 hours/day
- **Preschool (3–5 years)**: 10–13 hours/day

### Safe Sleep Guidelines
- Always place baby on their **back** to sleep
- Use a firm, flat surface with no soft bedding
- Keep the crib free of pillows, blankets, and stuffed animals
- Room-sharing (but not bed-sharing) is recommended for the first 6 months

### Building a Sleep Routine
A consistent bedtime routine helps signal to your child that sleep is coming:
1. Bath time
2. Gentle massage or lotion
3. Quiet feeding
4. Dimmed lights, soft music or white noise
5. Bed — drowsy but awake

### Night Wakings
Night wakings are normal, especially in the first year. Gradually encouraging self-soothing helps children sleep through the night. Avoid immediately picking up the baby at every sound — give them a moment to settle.
      ''',
      readTime: '4 min read',
      imageEmoji: '😴',
    ),

    // ── NUTRITION ───────────────────────────────────────────
    Article(
      id: 'n1',
      category: 'Nutrition',
      tag: 'NUTRITION',
      title: 'Top 10 Superfoods for Growing Toddlers',
      summary:
          'The best nutrient-dense foods to support your toddler\'s development.',
      content: '''
## Top 10 Superfoods for Growing Toddlers

Toddlers need a wide variety of nutrients to support rapid brain and body development. These foods pack the most nutritional punch.

### 1. Eggs
Rich in protein, healthy fats, and choline — critical for brain development. Scrambled, boiled, or as an omelette.

### 2. Lentils (Dhal)
Excellent source of iron, protein, and fibre. Easy to prepare and familiar in Sri Lankan cooking.

### 3. Leafy Greens (Gotukola, Spinach)
High in iron, folate, and vitamins A and C. Blend into curries or rice dishes.

### 4. Sweet Potato
Packed with beta-carotene, vitamin C, and potassium. Naturally sweet — children love it.

### 5. Yoghurt
Good source of calcium, protein, and probiotics for gut health. Choose plain full-fat yoghurt.

### 6. Oily Fish (Tuna, Mackerel)
Omega-3 fatty acids support brain and eye development. Aim for 2 servings per week.

### 7. Avocado
Healthy monounsaturated fats support brain growth. Great as a spread or mashed.

### 8. Bananas
Easy to digest, rich in potassium and B6. Perfect as a quick snack.

### 9. Whole Grains (Brown Rice, Oats)
Provide sustained energy and B vitamins. Swap white rice for brown occasionally.

### 10. Legumes (Chickpeas, Kidney Beans)
Plant-based protein and iron. Add to curries, soups, or mash into spreads.

### Tips
- Offer new foods repeatedly — it can take 10–15 exposures before a child accepts a new food
- Avoid adding salt or sugar to children's food
- Make mealtimes positive and pressure-free
      ''',
      readTime: '5 min read',
      imageEmoji: '🥦',
    ),
    Article(
      id: 'n2',
      category: 'Nutrition',
      tag: 'NUTRITION',
      title: 'Starting Solid Foods',
      summary: 'When and how to introduce solids safely for your baby.',
      content: '''
## Starting Solid Foods: A Parent\'s Guide

Introducing solid foods is an exciting milestone. Getting the timing and approach right sets the foundation for healthy eating habits.

### When to Start
- **Recommended age**: Around 6 months
- **Signs of readiness**:
  - Can sit with minimal support and hold head steady
  - Shows interest in food (watches others eat, reaches for food)
  - Has lost the tongue-thrust reflex (stops pushing food out automatically)

### First Foods to Try
- Single-grain cereals mixed with breast milk or formula
- Pureed vegetables: sweet potato, carrot, pumpkin
- Pureed fruits: banana, apple, pear
- Pureed meats: chicken, lentils

### How to Introduce New Foods
- Offer one new food at a time
- Wait 3–5 days before introducing another new food
- Watch for allergic reactions: rash, swelling, vomiting
- Start with 1–2 teaspoons and gradually increase

### Foods to Avoid Before 12 Months
- Honey (risk of botulism)
- Cow's milk as a main drink
- Salt and added sugar
- Whole nuts (choking hazard)
- Raw eggs

### Texture Progression
- **6–8 months**: Smooth purees
- **8–10 months**: Mashed and lumpy textures
- **10–12 months**: Soft finger foods
- **12+ months**: Family foods with modified texture
      ''',
      readTime: '5 min read',
      imageEmoji: '🍎',
    ),

    // ── PSYCHOLOGY ──────────────────────────────────────────
    Article(
      id: 'p1',
      category: 'Psychology',
      tag: 'PSYCHOLOGY',
      title: 'How to Soothe a Crying Baby Effectively',
      summary:
          'Understanding why babies cry and proven techniques to comfort them.',
      content: '''
## How to Soothe a Crying Baby Effectively

Crying is a baby\'s primary way of communicating. Learning to interpret and respond to different cries reduces stress for both parent and baby.

### Why Babies Cry
- **Hunger**: Most common reason, especially in newborns. Feed every 2–3 hours.
- **Tiredness**: Overtired babies are often harder to settle. Watch for sleep cues.
- **Discomfort**: Wet nappy, too hot or cold, clothing tags, gas pain.
- **Overstimulation**: Too much noise, light, or activity can overwhelm young babies.
- **Need for comfort**: Sometimes babies just need to be held.

### The 5 S\'s (Harvey Karp Method)
1. **Swaddle** — Wrap snugly with arms by the side
2. **Side/Stomach position** — Hold on side or stomach (only while awake and supervised)
3. **Shush** — Make a sustained "shhh" sound near the ear
4. **Swing** — Gentle rhythmic movement
5. **Suck** — Offer breast, pacifier, or clean finger

### Other Soothing Techniques
- Skin-to-skin contact (kangaroo care)
- White noise (fan, rain sounds, washing machine)
- Going for a walk or car ride
- Warm bath
- Baby massage

### When Crying Is Excessive
If your baby cries for more than 3 hours a day, more than 3 days a week, for more than 3 weeks — this is known as colic. It is not harmful but is exhausting. Talk to your PHM for support.

### Looking After Yourself
Never shake a baby. If you feel overwhelmed, put the baby down safely and take a short break. Reach out for help.
      ''',
      readTime: '5 min read',
      imageEmoji: '😊',
    ),
    Article(
      id: 'p2',
      category: 'Psychology',
      tag: 'PSYCHOLOGY',
      title: 'Building Secure Attachment',
      summary: 'How early bonding shapes your child\'s emotional development.',
      content: '''
## Building Secure Attachment

Attachment is the deep emotional bond between a child and their primary caregiver. Secure attachment in early life is one of the strongest predictors of mental health and wellbeing later on.

### What is Secure Attachment?
A securely attached child:
- Uses the caregiver as a safe base to explore from
- Seeks comfort when distressed and is soothed by the caregiver
- Trusts that their needs will be met

### How to Build Secure Attachment
**Respond consistently**
- Respond to your baby\'s cues promptly and warmly
- You cannot "spoil" a baby by responding to their needs

**Follow the baby\'s lead**
- Make eye contact during feeding and play
- Mirror your baby\'s expressions and sounds
- Follow what the baby is interested in

**Serve and return interactions**
- When a baby reaches out (with sounds, expressions, gestures) — respond
- This back-and-forth is the foundation of communication and trust

**Physical closeness**
- Holding, carrying, and skin-to-skin contact release oxytocin (the bonding hormone)
- Baby-wearing is an excellent way to maintain closeness during daily activities

### Attachment and Mental Health
Research consistently shows that secure attachment is linked to:
- Better emotional regulation
- Greater resilience
- Stronger social skills
- Higher academic achievement

### It\'s Never Too Late
If early bonding was difficult (due to NICU stay, postnatal depression, or other challenges), it is never too late to build a secure relationship. Consistent, responsive caregiving at any age helps.
      ''',
      readTime: '6 min read',
      imageEmoji: '❤️',
    ),

    // ── SAFETY ──────────────────────────────────────────────
    Article(
      id: 's1',
      category: 'Safety',
      tag: 'SAFETY',
      title: '2024 Vaccination Schedule Update',
      summary: 'The latest Sri Lanka national immunization programme schedule.',
      content: '''
## 2024 Sri Lanka Vaccination Schedule

The Sri Lanka National Immunization Programme (NIP) provides free vaccines to protect children from serious diseases.

### Birth
- **BCG** — Tuberculosis
- **Hepatitis B (1st dose)**

### 2 Months
- **Pentavalent (DPT-HepB-Hib) — 1st dose** — Diphtheria, Pertussis, Tetanus, Hepatitis B, Haemophilus influenzae type b
- **Oral Polio Vaccine (OPV) — 1st dose**
- **Pneumococcal Conjugate Vaccine (PCV) — 1st dose**

### 4 Months
- **Pentavalent — 2nd dose**
- **OPV — 2nd dose**
- **PCV — 2nd dose**

### 6 Months
- **Pentavalent — 3rd dose**
- **OPV — 3rd dose**

### 9 Months
- **Measles (MR) — 1st dose**

### 12 Months
- **PCV — Booster**

### 18 Months
- **MR — 2nd dose**
- **DPT — Booster**
- **OPV — Booster**

### 5 Years
- **DT — Booster**
- **OPV — Booster**

### Where to Get Vaccinated
Vaccines are available free of charge at:
- Your local MOH (Medical Officer of Health) clinic
- Public hospitals
- PHM (Public Health Midwife) home visits

### Important Notes
- Always bring your child health record book
- Inform the health worker of any previous reactions
- After vaccination, stay at the clinic for 15–30 minutes for observation
      ''',
      readTime: '4 min read',
      imageEmoji: '💉',
    ),
    Article(
      id: 's2',
      category: 'Safety',
      tag: 'SAFETY',
      title: 'Childproofing Your Home',
      summary:
          'Essential safety measures to protect your crawling and walking baby.',
      content: '''
## Childproofing Your Home

As babies become mobile, the home environment needs to be made safe. Most childhood accidents happen at home and are preventable.

### Falls
- Install safety gates at the top and bottom of stairs
- Use non-slip mats in the bath and on hard floors
- Never leave a baby unattended on a raised surface (changing table, sofa)
- Keep furniture with sharp corners padded or covered

### Choking and Suffocation
- Keep small objects (coins, buttons, batteries) out of reach
- Cut food into small pieces for toddlers
- Keep plastic bags, balloons, and string out of reach
- Check toys for small parts

### Poisoning
- Keep all medicines locked away
- Store cleaning products in high, locked cupboards
- Do not store chemicals in food containers
- Keep the Poisons Information Centre number saved: **0112 686 143**

### Burns and Scalds
- Keep hot drinks and food away from table edges
- Set water heater temperature to below 50°C
- Use back burners on the stove and turn handles inward
- Keep children away from irons, ovens, and fireplaces

### Drowning
- Never leave a child alone near water — even 2cm is enough to drown in
- Empty buckets, tubs, and paddling pools immediately after use
- Install fences around garden ponds or pools

### Electrical Safety
- Use outlet covers on all unused sockets
- Keep cords out of reach and tidy
- Do not use electrical appliances near water
      ''',
      readTime: '5 min read',
      imageEmoji: '🏠',
    ),
  ];

  static List<Article> getByCategory(String category) {
    if (category == 'All') return articles;
    return articles.where((a) => a.category == category).toList();
  }

  static Article? getSpotlight() {
    try {
      return articles.firstWhere((a) => a.isSpotlight);
    } catch (_) {
      return articles.isNotEmpty ? articles.first : null;
    }
  }

  static List<Article> getLatestUpdates() {
    return articles.where((a) => !a.isSpotlight).toList();
  }
}
