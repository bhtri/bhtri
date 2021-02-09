const axios = require("axios");
const fs = require("fs");

const getQuote = async () => {
  try {
    const { data } = await axios.get("https://quotes.rest/qod?language=en");
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
  const str = `*${today}の名言 *\n\n_**${quote}**_\n\n${author}`;
  
  fs.writeFileSync("README.md", str);
};

generate();
