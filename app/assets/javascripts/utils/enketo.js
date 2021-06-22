import { Form } from 'enketo-core';
import transformer from 'enketo-transformer';
// const transformer = require('enketo-transformer');

// The XSL transformation result contains a HTML Form and XML instance.
// These can be obtained dynamically on the client, or at the server/
// In this example we assume the HTML was injected at the server and modelStr
// was injected as a global variable inside a <script> tag.

async function getModelStr() {
  const xform = `<?xml version="1.0"?>
<h:html xmlns="http://www.w3.org/2002/xforms" xmlns:ev="http://www.w3.org/2001/xml-events" xmlns:h="http://www.w3.org/1999/xhtml" xmlns:jr="http://openrosa.org/javarosa" xmlns:orx="http://openrosa.org/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <h:head>
    <h:title>basic</h:title>
    <model>
      <instance>
        <basic id="basic">
          <height/>
        </basic>
      </instance>
      <bind nodeset="height" type="int"/>
    </model>
  </h:head>
  <h:body>
    <input ref="height">
      <label>what is your height</label>
    </input>
  </h:body>
</h:html>
`;

  // return xform;
  return transformer.transform({
    // required string of XForm
    xform,
    // optional string, to add theme if no theme is defined in the XForm
    theme: '',
    // optional map, to replace jr://..../myfile.png URLs
    media: {
      'myfile.png': '/path/to/somefile.png',
    },
    // optional ability to disable markdown rendering (default is true)
    markdown: false,
    // optional preprocess function that transforms the XForm (as libXMLJs object) to
    // e.g. correct incompatible XForm syntax before Enketo's transformation takes place
    preprocess: (doc) => doc,
  });
}

async function inject() {
  // required HTML Form DOM element
  const formEl = document.querySelector('form.enketo');

  const modelStr = await getModelStr();

  // required object containing data for the form
  const data = {
    // required string of the default instance defined in the XForm
    modelStr,
    // optional string of an existing instance to be edited
    instanceStr: null,
    // optional boolean whether this instance has ever been submitted before
    submitted: false,
    // optional array of external data objects containing:
    // {id: 'someInstanceId', xml: XMLDocument}
    external: [],
    // optional object of session properties
    // 'deviceid', 'username', 'email', 'phonenumber', 'simserial', 'subscriberid'
    session: {},
  };

  // Form-specific configuration
  const options = {};

  // Instantiate a form, with 2 parameters
  const form = new Form(formEl, data, options);

  // Initialize the form and capture any load errors
  let loadErrors = form.init();

  // If desired, scroll to a specific question with any XPath location expression,
  // and aggregate any loadErrors.
  loadErrors = loadErrors.concat(form.goTo('//repeat[3]/node'));

  // submit button handler for validate button
  $('#submit')
    .on('click', async () => {
      // clear non-relevant questions and validate
      const valid = await form.validate();

      if (!valid) {
        alert('Form contains errors. Please see fields marked in red.');
      } else {
        // Record is valid!
        const record = form.getDataStr();

        // reset the form view
        form.resetView();

        // reinstantiate a new form with the default model and no options
        form = new Form(formEl, { modelStr }, {});

        // do what you want with the record
      }
    });
}

// Run the async method.
inject();
