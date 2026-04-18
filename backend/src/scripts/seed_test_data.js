/**
 * CommunityBridge - Test Data Seed Script
 * 
 * This script:
 * 1. Creates a "Community Needs Assessment" survey if one doesn't exist
 * 2. Injects 20 approved mock responses from different Indian cities
 *    with realistic coordinates for heatmap testing
 * 3. Ready for AI Analyzer to process
 * 
 * Usage: node src/scripts/seed_test_data.js <orgId>
 */

require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { db } = require('../config/firebase');

const ORG_ID = process.argv[2];

if (!ORG_ID) {
  console.error('❌ ERROR: Please provide orgId as argument: node src/scripts/seed_test_data.js <orgId>');
  process.exit(1);
}

// Indian cities with realistic coordinates
const indianCities = [
  { city: 'Mumbai, Maharashtra',    lat: 19.0760, lng: 72.8777 },
  { city: 'Delhi, NCR',             lat: 28.7041, lng: 77.1025 },
  { city: 'Bengaluru, Karnataka',   lat: 12.9716, lng: 77.5946 },
  { city: 'Hyderabad, Telangana',   lat: 17.3850, lng: 78.4867 },
  { city: 'Chennai, Tamil Nadu',    lat: 13.0827, lng: 80.2707 },
  { city: 'Kolkata, West Bengal',   lat: 22.5726, lng: 88.3639 },
  { city: 'Jaipur, Rajasthan',      lat: 26.9124, lng: 75.7873 },
  { city: 'Lucknow, Uttar Pradesh', lat: 26.8467, lng: 80.9462 },
  { city: 'Bhopal, Madhya Pradesh', lat: 23.2599, lng: 77.4126 },
  { city: 'Patna, Bihar',           lat: 25.5941, lng: 85.1376 },
  { city: 'Ahmedabad, Gujarat',     lat: 23.0225, lng: 72.5714 },
  { city: 'Pune, Maharashtra',      lat: 18.5204, lng: 73.8567 },
  { city: 'Surat, Gujarat',         lat: 21.1702, lng: 72.8311 },
  { city: 'Kanpur, Uttar Pradesh',  lat: 26.4499, lng: 80.3319 },
  { city: 'Nagpur, Maharashtra',    lat: 21.1458, lng: 79.0882 },
  { city: 'Indore, Madhya Pradesh', lat: 22.7196, lng: 75.8577 },
  { city: 'Varanasi, Uttar Pradesh',lat: 25.3176, lng: 82.9739 },
  { city: 'Guwahati, Assam',        lat: 26.1445, lng: 91.7362 },
  { city: 'Bhubaneswar, Odisha',    lat: 20.2961, lng: 85.8245 },
  { city: 'Thiruvananthapuram, Kerala', lat: 8.5241, lng: 76.9366 },
];

// Realistic humanitarian survey response data
const responseTemplates = [
  {
    volunteers: 'Ravi Kumar',      needType: 'Food', severity: 'Critical',
    headcount: 85,  waterDays: 0, medicalNeeds: 'None',       accessRoad: 'Yes', notes: 'Families without food for 3 days. Ration shop closed. Children are going hungry.'
  },
  {
    volunteers: 'Priya Sharma',    needType: 'Medical', severity: 'High',
    headcount: 42,  waterDays: 2, medicalNeeds: 'Diarrhea, Fever', accessRoad: 'Yes', notes: 'Outbreak of waterborne disease. No mobile clinic in 30km. Elders seriously ill.'
  },
  {
    volunteers: 'Anil Singh',      needType: 'Shelter', severity: 'Critical',
    headcount: 120, waterDays: 1, medicalNeeds: 'Injuries',   accessRoad: 'No',  notes: 'Flood destroyed 20 homes. 120 people sleeping in school. No dry clothes.'
  },
  {
    volunteers: 'Sunita Reddy',    needType: 'Water', severity: 'High',
    headcount: 210, waterDays: 0, medicalNeeds: 'Skin rashes', accessRoad: 'Yes', notes: 'Main pipeline broken. Community using pond water. High contamination risk.'
  },
  {
    volunteers: 'Manoj Patel',     needType: 'Food', severity: 'Moderate',
    headcount: 65,  waterDays: 3, medicalNeeds: 'None',       accessRoad: 'Yes', notes: 'Supply chain disruption. Market closed for 5 days. Elderly people especially affected.'
  },
  {
    volunteers: 'Deepa Nair',      needType: 'Medical', severity: 'Critical',
    headcount: 30,  waterDays: 2, medicalNeeds: 'Dengue cases', accessRoad: 'No', notes: 'Two dengue deaths this week. No medical supplies. Road flooded, ambulance cannot reach.'
  },
  {
    volunteers: 'Kareem Hassan',   needType: 'Shelter', severity: 'High',
    headcount: 90,  waterDays: 1, medicalNeeds: 'Minor injuries', accessRoad: 'Yes', notes: 'Cyclone damaged roofs of 15 houses. Monsoon rain entering homes. Need tarpaulins.'
  },
  {
    volunteers: 'Lata Desai',      needType: 'Education', severity: 'Moderate',
    headcount: 350, waterDays: 5, medicalNeeds: 'None',       accessRoad: 'Yes', notes: 'School turned into relief camp. 350 children miss education. Need temporary learning space.'
  },
  {
    volunteers: 'Arjun Mehta',     needType: 'Food', severity: 'Critical',
    headcount: 160, waterDays: 0, medicalNeeds: 'Malnutrition', accessRoad: 'No', notes: 'Tribal village cut off by landslide. Children severely malnourished. No food for 4 days.'
  },
  {
    volunteers: 'Fatima Begum',    needType: 'Water', severity: 'High',
    headcount: 180, waterDays: 0, medicalNeeds: 'Stomach issues', accessRoad: 'Yes', notes: 'Borewell broken. Women walking 5km for water daily. High contamination in local source.'
  },
  {
    volunteers: 'Rajesh Yadav',    needType: 'Medical', severity: 'High',
    headcount: 55,  waterDays: 2, medicalNeeds: 'TB, chest infections', accessRoad: 'Yes', notes: 'Multiple TB cases identified. Overcrowded relief camp. Need isolation ward.'
  },
  {
    volunteers: 'Meena Krishnan',  needType: 'Shelter', severity: 'Moderate',
    headcount: 75,  waterDays: 2, medicalNeeds: 'None',       accessRoad: 'Yes', notes: '12 families in temporary tents. Approaching winter nights. Need insulated shelter.'
  },
  {
    volunteers: 'Suresh Babu',     needType: 'Food', severity: 'High',
    headcount: 100, waterDays: 1, medicalNeeds: 'Dehydration', accessRoad: 'Yes', notes: 'Drought conditions. Crops failed. Families skipping meals. Government aid not reached.'
  },
  {
    volunteers: 'Anita Gupta',     needType: 'Water', severity: 'Critical',
    headcount: 290, waterDays: 0, medicalNeeds: 'Cholera symptoms', accessRoad: 'No', notes: 'River flooded sewage system. ENTIRE village water supply contaminated. Cholera risk HIGH.'
  },
  {
    volunteers: 'Vikram Joshi',    needType: 'Medical', severity: 'Moderate',
    headcount: 40,  waterDays: 3, medicalNeeds: 'Snake bites, infections', accessRoad: 'No', notes: 'Flood drove snakes into homes. Three bites in a week. Antivenom stock depleted.'
  },
  {
    volunteers: 'Pallavi Iyer',    needType: 'Education', severity: 'High',
    headcount: 220, waterDays: 4, medicalNeeds: 'None',       accessRoad: 'Yes', notes: 'Schools damaged by storm. 220 students out of education for 3 weeks. No alternative venue.'
  },
  {
    volunteers: 'Dinesh Rawat',    needType: 'Food', severity: 'Critical',
    headcount: 135, waterDays: 0, medicalNeeds: 'Weakness', accessRoad: 'No', notes: 'Remote mountain area. Supply helicopter can\'t fly due to weather. Critical food shortage.'
  },
  {
    volunteers: 'Rekha Tiwari',    needType: 'Shelter', severity: 'High',
    headcount: 200, waterDays: 1, medicalNeeds: 'Respiratory issues', accessRoad: 'Yes', notes: 'Fire destroyed half of slum colony. 200 displaced. Living in open. Need tents urgently.'
  },
  {
    volunteers: 'Mohan Das',       needType: 'Medical', severity: 'Critical',
    headcount: 60,  waterDays: 1, medicalNeeds: 'Post-flood infections', accessRoad: 'Yes', notes: 'Open wounds infected due to flood water contact. No antibiotics available in 40km.'
  },
  {
    volunteers: 'Shalini Rao',     needType: 'Water', severity: 'Moderate',
    headcount: 150, waterDays: 1, medicalNeeds: 'Dehydration', accessRoad: 'Yes', notes: 'Seasonal shortage. Community tanker comes once every 3 days. Need storage infrastructure.'
  },
];

const fakeSurveyFields = [
  { id: 'f1', label: 'Volunteer Name', type: 'text', required: true, options: [] },
  { id: 'f2', label: 'Primary Need Type', type: 'dropdown', required: true, options: ['Food', 'Medical', 'Shelter', 'Water', 'Education'] },
  { id: 'f3', label: 'Situation Severity', type: 'multiplechoice', required: true, options: ['Critical', 'High', 'Moderate', 'Low'] },
  { id: 'f4', label: 'Estimated Headcount Affected', type: 'number', required: true, options: [] },
  { id: 'f5', label: 'Days Without Clean Water', type: 'number', required: true, options: [] },
  { id: 'f6', label: 'Medical Needs Observed', type: 'text', required: false, options: [] },
  { id: 'f7', label: 'Is Road Access Available?', type: 'dropdown', required: true, options: ['Yes', 'No', 'Partially'] },
  { id: 'f8', label: 'Field Notes & Observations', type: 'text', required: false, options: [] },
];

async function seedData() {
  console.log('\n🌱 CommunityBridge Test Data Seeder');
  console.log('====================================');
  console.log(`📌 OrgId: ${ORG_ID}\n`);

  // 1. Create (or find existing) survey
  console.log('📋 Step 1: Creating survey...');
  
  const existingSnap = await db.collection('surveys')
    .where('orgId', '==', ORG_ID)
    .where('title', '==', 'Need Survey')
    .limit(1)
    .get();

  let surveyId, surveyCode;

  if (!existingSnap.empty) {
    const existing = existingSnap.docs[0];
    surveyId = existing.id;
    surveyCode = existing.data().surveyCode;
    console.log(`✅ Found existing survey: ${surveyCode} (${surveyId})`);
  } else {
    surveyCode = 'NEEDS-' + Math.random().toString(36).substring(2, 6).toUpperCase();
    const surveyRef = db.collection('surveys').doc();
    surveyId = surveyRef.id;
    await surveyRef.set({
      orgId: ORG_ID,
      title: 'Need Survey',
      description: 'Field volunteer survey to assess urgent community needs across disaster-affected areas. Data collected is used to dispatch aid and volunteers.',
      surveyCode,
      fields: fakeSurveyFields,
      createdAt: new Date(),
      isActive: true
    });
    console.log(`✅ Created new survey: ${surveyCode} (${surveyId})`);
  }

  // 2. Inject 20 mock responses (approved, with locations from Indian cities)
  console.log('\n🗺️  Step 2: Injecting 20 approved responses from across India...');
  
  const batch = db.batch();
  const now = new Date();

  for (let i = 0; i < indianCities.length; i++) {
    const cityInfo = indianCities[i];
    const template = responseTemplates[i];
    
    const respRef = db.collection('responses').doc();
    const submittedAt = new Date(now.getTime() - (Math.random() * 48 * 60 * 60 * 1000)); // random within last 48h

    batch.set(respRef, {
      orgId: ORG_ID,
      surveyId: surveyCode,
      volunteerId: template.volunteers,
      status: 'approved',
      submittedAt,
      syncedAt: new Date(),
      location: {
        lat: cityInfo.lat + (Math.random() - 0.5) * 0.01, // tiny jitter for realism
        lng: cityInfo.lng + (Math.random() - 0.5) * 0.01,
      },
      locationName: cityInfo.city,
      answers: [
        { fieldId: 'f1', value: template.volunteers },
        { fieldId: 'f2', value: template.needType },
        { fieldId: 'f3', value: template.severity },
        { fieldId: 'f4', value: String(template.headcount) },
        { fieldId: 'f5', value: String(template.waterDays) },
        { fieldId: 'f6', value: template.medicalNeeds },
        { fieldId: 'f7', value: template.accessRoad },
        { fieldId: 'f8', value: template.notes },
      ]
    });
    
    console.log(`  ✓ ${cityInfo.city} → ${template.needType} (${template.severity}) — ${template.headcount} affected`);
  }
  
  await batch.commit();
  console.log(`\n✅ Successfully injected 20 responses into Firestore.`);
  
  // Summary
  console.log('\n📊 Summary');
  console.log('===========');
  console.log(`Survey Code: ${surveyCode}`);
  console.log(`Survey ID:   ${surveyId}`);
  console.log(`Responses:   20 (all "approved" and ready for AI analysis)`);
  console.log(`\n🎯 Next Steps:`);
  console.log('  1. Open http://localhost:5173');
  console.log('  2. Navigate to Surveys → see "Community Needs Assessment Survey"');
  console.log('  3. Navigate to Responses → check the 20 city responses');
  console.log('  4. Go to Dashboard → click "Run AI Analysis"');
  console.log('  5. Check the heatmap and urgency charts\n');
  
  process.exit(0);
}

seedData().catch(err => {
  console.error('❌ Seeder failed:', err);
  process.exit(1);
});
