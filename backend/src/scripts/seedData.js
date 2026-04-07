/**
 * Generates mock data based on prompt specifications to easily test logic.
 * Requirements:
 * 1 org: "Helping Hands NGO" based in Bhopal, India
 * 1 survey: Name, Age, Location Description, Primary Need, Number of People, Additional Notes
 * 10 volunteers with different skills and locations across Bhopal
 * 80 survey responses across 6 areas of Bhopal with status 'approved'
 */
require('dotenv').config();
const { db } = require('../config/firebase');
const { calculateDistance } = require('../utils/distanceCalculator');

async function seedData() {
  try {
    console.log('Seeding Data...');

    // 1. Create Organization
    const orgRef = db.collection('organisations').doc('helping-hands');
    await orgRef.set({
      name: 'Helping Hands NGO',
      email: 'contact@helpinghands.demo',
      location: 'Bhopal, India',
      createdAt: new Date()
    });

    const orgId = orgRef.id;

    // 2. Create Survey
    const surveyRef = db.collection('surveys').doc('survey-demo-1');
    await surveyRef.set({
      orgId,
      title: 'Community Needs Survey Bhopal',
      description: 'Collect post-disaster critical data',
      surveyCode: 'BHOPAL12',
      fields: [
        { id: 'f1', label: 'Name', type: 'text', required: true },
        { id: 'f2', label: 'Age', type: 'number', required: false },
        { id: 'f3', label: 'Location Description', type: 'text', required: true },
        { id: 'f4', label: 'Primary Need', type: 'dropdown', required: true, options: ['food', 'medical', 'shelter', 'water', 'education'] },
        { id: 'f5', label: 'Number of People', type: 'number', required: true },
        { id: 'f6', label: 'Additional Notes', type: 'text', required: false }
      ],
      createdAt: new Date(),
      isActive: true
    });

    // 3. Create Volunteers (10 volunteers)
    const skillsList = [['medical'], ['logistics'], ['education'], ['shelter', 'construction'], ['counselling'], ['medical', 'logistics']];
    // Base lat lng of Bhopal is 23.2599° N, 77.4126° E.
    const volunteerBatch = db.batch();
    for (let i = 1; i <= 10; i++) {
        const vRef = db.collection('volunteers').doc(`v-demo-${i}`);
        volunteerBatch.set(vRef, {
            name: `Volunteer ${i}`,
            email: `volunteer${i}@demo.com`,
            phone: `+91987654320${i}`,
            orgId,
            skills: skillsList[i % skillsList.length],
            availability: true,
            location: {
                // random offsets within Bhopal
                lat: 23.2599 + (Math.random() - 0.5) * 0.1,
                lng: 77.4126 + (Math.random() - 0.5) * 0.1
            },
            fcmToken: `fake-token-${i}`,
            createdAt: new Date()
        });
    }
    await volunteerBatch.commit();

    // 4. Create 80 Responses (across 6 areas)
    const areas = ['MP Nagar', 'TT Nagar', 'Ayodhya Bypass', 'Bairagarh', 'Kolar', 'Awadhpuri'];
    const responseBatch1 = db.batch();
    const responseBatch2 = db.batch();

    for (let i = 0; i < 80; i++) {
        const areaIndex = i % areas.length;
        const rRef = db.collection('responses').doc();
        const responseObj = {
            surveyId: 'survey-demo-1',
            orgId,
            volunteerId: `v-demo-${(i % 10) + 1}`,
            answers: [
                { fieldId: 'f1', value: `Resident ${i}` },
                { fieldId: 'f2', value: 20 + (i % 40) },
                { fieldId: 'f3', value: `Area: ${areas[areaIndex]}` },
                { fieldId: 'f4', value: ['food', 'medical', 'shelter', 'water', 'education'][i % 5] },
                { fieldId: 'f5', value: 1 + (i % 10) },
                { fieldId: 'f6', value: 'Need help ASAP' }
            ],
            location: {
                lat: 23.2599 + (Math.random() - 0.5) * 0.08,
                lng: 77.4126 + (Math.random() - 0.5) * 0.08
            },
            status: 'approved',
            submittedAt: new Date(),
            syncedAt: new Date()
        };
        
        if (i < 40) {
           responseBatch1.set(rRef, responseObj);
        } else {
           responseBatch2.set(rRef, responseObj);
        }
    }
    
    await responseBatch1.commit();
    await responseBatch2.commit();

    console.log('Successfully seeded database!');
    process.exit(0);

  } catch (err) {
      console.error(err);
      process.exit(1);
  }
}

seedData();
