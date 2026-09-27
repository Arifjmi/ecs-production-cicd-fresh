const http = require("http");

const request = http.request(
  {
    hostname: "127.0.0.1",
    port: 3000,
    path: "/health",
    method: "GET"
  },
  (response) => {

    let data = "";

    response.on("data", (chunk) => {
      data += chunk;
    });

    response.on("end", () => {

      if (response.statusCode !== 200) {
        console.error("Test failed: HTTP status is not 200");
        process.exit(1);
      }

      const result = JSON.parse(data);

      if (result.status !== "UP") {
        console.error("Test failed: application status is not UP");
        process.exit(1);
      }

      console.log("Application health test passed");
    });
  }
);

request.on("error", (error) => {
  console.error("Test failed:", error.message);
  process.exit(1);
});

request.end();
