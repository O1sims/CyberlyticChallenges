package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/globalsign/mgo/bson"
	"github.com/globalsign/mgo"
	"github.com/gorilla/mux"
)


var peopleColl = "people"

type person struct {
	ID      bson.ObjectId `json:"id" bson:"_id,omitempty"`
	Name    string        `json:"name"`
	Age     uint8         `json:"age"`
}

type personHandler struct {
	db *mgo.Database
}

func newHandler(db *mgo.Database) *personHandler {
	return &personHandler{
		db: db,
	}
}

func (handler *personHandler) post(responseWriter http.ResponseWriter, request *http.Request) {
	person := new(person)
	json.NewDecoder(request.Body).Decode(&person)

	person.ID = bson.NewObjectId()
	handler.db.C(peopleColl).Insert(person)
	log.Printf("Created: %v", person)

	responseWriter.WriteHeader(http.StatusOK)
	fmt.Fprintf(responseWriter, "%v", person.ID.Hex())
}

func (handler *personHandler) list(responseWriter http.ResponseWriter, request *http.Request) {
	people := []person{}
	handler.db.C(peopleColl).Find(bson.M{}).All(&people)

	if len(people) == 0 {
		log.Printf("No users found!")
		responseWriter.WriteHeader(http.StatusNotFound)
	} else {
		log.Printf("Found %v users!", len(people))
		responseWriter.WriteHeader(http.StatusFound)
	}

	responseWriter.Header().Set("Content-Type", "application/json")
	json.NewEncoder(responseWriter).Encode(people)
}

func (handler *personHandler) get(responseWriter http.ResponseWriter, request *http.Request) {
	vars := mux.Vars(request)
	id := bson.ObjectIdHex(vars["person_id"])

	person := new(person)
	log.Printf("Searching for user %v...", id.Hex())

	count, _ := handler.db.C(peopleColl).Find(bson.M{"_id": id}).Count()
	if count < 1 {
		log.Printf("Not Found: %v", id.Hex())
		responseWriter.WriteHeader(http.StatusNotFound)
	} else {
		log.Printf("Found: %v", id.Hex())
		responseWriter.WriteHeader(http.StatusFound)
		handler.db.C(peopleColl).Find(bson.M{"_id": id}).One(&person)
	}

	responseWriter.Header().Set("Content-Type", "application/json")
	json.NewEncoder(responseWriter).Encode(person)
}

func (handler *personHandler) delete(responseWriter http.ResponseWriter, request *http.Request) {
	vars := mux.Vars(request)
	id := bson.ObjectIdHex(vars["person_id"])

	log.Printf("Removing user(s) with id: %v...", id.Hex())
	handler.db.C(peopleColl).Remove(bson.M{"_id": id})
	log.Printf("Removed!")

	responseWriter.WriteHeader(http.StatusOK)
	fmt.Fprintf(responseWriter, "Success!")
}

func (handler *personHandler) deleteAll(responseWriter http.ResponseWriter, request *http.Request) {
	log.Printf("Removing all users...")
	handler.db.C(peopleColl).RemoveAll(bson.M{})
	log.Printf("Removed all users!")

	responseWriter.WriteHeader(http.StatusOK)
	fmt.Fprintf(responseWriter, "Success!")
}

func defaultHandler(responseWriter http.ResponseWriter, request *http.Request) {
	log.Printf("Sending default response...")
	responseWriter.WriteHeader(http.StatusOK)
	fmt.Fprintf(responseWriter, "Ready!")
}

func notFoundHandler(responseWriter http.ResponseWriter, request *http.Request) {
	log.Printf("Not found! %v", request.URL)
	responseWriter.WriteHeader(http.StatusNotFound)
	fmt.Fprintf(responseWriter, "Not Found!")
}

func handleJSONMarshallingError(responseWriter http.ResponseWriter, err error) {
	handleError(responseWriter, err, http.StatusInternalServerError)
}

func handleError(responseWriter http.ResponseWriter, err error, responseCode int) {
	http.Error(responseWriter, err.Error(), responseCode)
}

func getEnvVar(key, defaultVal string) (value string) {
	value = os.Getenv(key)
	if len(value) != 0 {
		log.Printf("Found env variable! [%v = '%v']", key, value)
		return value
	}

	if len(defaultVal) != 0 {
		log.Printf("Defaulted env variable! [%v = '%v']", key, defaultVal)
		return defaultVal
	}

	panic(fmt.Sprintf("Missing env variable! [%v]", key))
}

func main() {
	port := getEnvVar("APP_PORT", "8081")
	dbHost := getEnvVar("APP_MONGO_HOST", "localhost")
	dbPort := getEnvVar("APP_MONGO_PORT", "27017")
	dbName := getEnvVar("APP_MONGO_DB", "App_DB")

	log.Printf("Connecting to db...")
	session, err := mgo.Dial(fmt.Sprintf("%v:%v", dbHost, dbPort))
	if err != nil {
		log.Fatalf("Unable to connect to db! %v", err)
	}
	defer session.Close()
	db := session.DB(dbName)

	personHandler := newHandler(db)

	router := mux.NewRouter().StrictSlash(true)
	router.NotFoundHandler = http.HandlerFunc(notFoundHandler)

	router.HandleFunc("/", defaultHandler).Methods("GET")
	router.HandleFunc("/people", personHandler.post).Methods("POST")
	router.HandleFunc("/people", personHandler.list).Methods("GET")
	router.HandleFunc("/people/{person_id}", personHandler.get).Methods("GET")
	router.HandleFunc("/people", personHandler.deleteAll).Methods("DELETE")
	router.HandleFunc("/people/{person_id}", personHandler.delete).Methods("DELETE")

	address := fmt.Sprintf(":%v", port)
	log.Printf("Listening... %v", address)
	http.ListenAndServe(address, router)
}
