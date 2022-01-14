const axios = require("axios");
const fs = require("fs");

const template = fs.readFileSync(`${__dirname}/Template.md`, "utf-8");

fs.writeFileSync("README.md", template);

const readme = fs.readFileSync(`${__dirname}/README.md`, "utf-8");

// https://stackoverflow.com/a/62212128/6284714
const agent = new https.Agent({
    rejectUnauthorized: false
});

const getQuote = async () => {
  try {
    const { data } = await axios.get("https://quotes.rest/qod?language=en", { httpsAgent: agent });
    const quote = data.contents.quotes[0].quote;
    const author = data.contents.quotes[0].author;

    console.log("new quote", `"${quote}"`);

    return {
      quote,
      author,
    };
  } catch (err) {
    console.error(err.message);
    return {};
  }
};

const generate = async () => {
  const { quote, author } = await getQuote();

  if (!quote) return;

  const curDate = new Date();
  const dd = String(curDate.getDate()).padStart(2, `0`);
  const mm = String(curDate.getMonth() + 1).padStart(2, `0`);
  const yyyy = String(curDate.getFullYear()).padStart(4, `0`);
  const today =　yyyy + `年` + mm + `月` + dd + `日`;
  const title = `${today}の名言`;

  let newReadme = readme.replace(/{%TITLE%}/g, title);
  newReadme = newReadme.replace(/{%QUOTE%}/g, quote);
  newReadme = newReadme.replace(/{%AUTHOR%}/g, author);

  fs.writeFileSync("README.md", newReadme);
};

generate();
