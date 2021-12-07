package main

import (
	"log"
	"os"
	"regexp"
)

func main() {
	basebytes, err := os.ReadFile("./dot_base.vim")
	if err != nil {
		log.Fatalf("dot_base: %v", err)
		return
	}
	basecontent := string(basebytes)

	re := regexp.MustCompile(`"include\(\s*(.+)\s*\)`)
	basecontent = re.ReplaceAllStringFunc(basecontent, func(inc string) string {
		incfile := re.ReplaceAllString(inc, "$1")
		log.Print(incfile)

		b, err := os.ReadFile("./" + incfile)
		if err != nil {
			log.Fatalf("%s: %v", incfile, err)
			return ""
		}
		//log.Print(string(b))
		return inc + "\n" + string(b)
	})

	err = os.WriteFile("./dot.vim", []byte(basecontent), os.ModePerm)
	if err != nil {
		log.Fatalf("dot: %v", err)
		return
	}
}
