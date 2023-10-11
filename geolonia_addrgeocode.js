const fs = require('fs');
const { config, normalize } = require('@geolonia/normalize-japanese-addresses');

// Set the local file path to the Japanese Addresses API
config.japaneseAddressesApi = 'file:///Users/jamestodd/Desktop/Work/Keiji/JapanVisit_Oct23/ChochoMoves/normalize-japanese-addresses/japanese-addresses-master/api/ja';

// Parse command-line arguments
const args = process.argv.slice(2); // Skip the first two arguments (node executable and script filename)

if (args.length !== 2) {
  console.error('Usage: node geocode.js <inputFile> <outputFile>');
  process.exit(1);
}

const inputFile = args[0];
const outputFile = args[1];

fs.readFile(inputFile, 'utf8', async (err, data) => {
  if (err) {
    console.error(err);
    return;
  }

  // Split the input data into an array of lines (one address per line)
  const addresses = data.trim().split('\n');

  // Initialize an array to store the normalized results as objects
  const normalizedResults = [];

  // Add column headings to the CSV
  const columnHeadings = ['Input Address', 'Prefecture', 'City', 'Town', 'Address', 'Level', 'Latitude', 'Longitude'];

  // Normalize each address
  for (const address of addresses) {
    // Normalize the address
    const normalizedResult = await normalize(address);

    // Add the original input address to the normalized result object
    normalizedResult.input = address;

    normalizedResults.push(normalizedResult);
  }

  // Create an array to store CSV rows, starting with the column headings
  const csvData = [columnHeadings.join(',')];

  // Convert the normalized results into CSV rows
  normalizedResults.forEach((result) => {
    const rowData = [
      result.input, // Use the input address
      result.pref,
      result.city,
      result.town,
      result.addr,
      result.level,
      result.lat,
      result.lng,
    ];
    csvData.push(rowData.join(','));
  });

  // Write the CSV data to the output file
  fs.writeFile(outputFile, csvData.join('\n'), 'utf8', (err) => {
    if (err) {
      console.error(err);
    } else {
      console.log(`Normalized addresses saved to ${outputFile}`);
    }
  });
});
