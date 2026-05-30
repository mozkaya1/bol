package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/PuerkitoBio/goquery"
)

type data struct {
	Url    string `json:"url"`
	Price  int    `json:"price"`
	Status int    `json:"status"`
}

func (output *data) getPrice() data {

	url := "https://www.bol.com/nl/nl/p/knip-sleuteltang-8603125/9200000076969628"

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.Println(err)
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36 OPR/94.0.0.0")

	resp, err := http.DefaultClient.Do(req)
	// _, err = io.ReadAll(resp.Body)
	// if err != nil {
	// 	log.Println(err)
	// }
	defer resp.Body.Close()

	// body, err := io.ReadAll(resp.Body)
	// if err != nil {
	// 	log.Println(err)
	// }

	doc, err := goquery.NewDocumentFromReader(resp.Body)
	if err != nil {
		log.Println(err)
	}

	price := doc.Find("span.row-span-2").First().Text()
	// fmt.Println(string(output))
	output.Status = resp.StatusCode
	output.Url = url
	if price != "" {
		output.Price, err = strconv.Atoi(price)
	}
	if err != nil {
		log.Println(err)
	}
	return *output
}

func main() {
	var output data
	data := output.getPrice()
	json.NewEncoder(os.Stdout).Encode(data)

}
