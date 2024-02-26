package main

import (
    "context"
    "database/sql"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"

    "cloud.google.com/go/pubsub"
    "github.com/gin-gonic/gin"
    _ "github.com/go-sql-driver/mysql"
    "github.com/jmoiron/sqlx"
)

type Person struct {
    ID       string `json:"id" binding:"required"`
    Name     string `json:"name" binding:"required"`
    LastName string `json:"last_name" binding:"required"`
    FieldA   string `json:"field_a"`
    FieldB   string `json:"field_b"`
    FieldC   string `json:"field_c"`
}

const insertSQL = `INSERT INTO lc_table (ID, Name, LastName, FieldA, FieldB, FieldC) VALUES (?, ?, ?, ?, ?, ?)`

var (
    db             *sqlx.DB
    pubSubClient   *pubsub.Client
    pubSubTopic    *pubsub.Topic
    dbUser         string
    dbPass         string
    dbName         string
    dbInstance     string
    pubSubTopicID  string
    connectionName string
)

func main() {
    var err error

    // Load environment variables
    dbUser = os.Getenv("DB_USER")
    dbName = os.Getenv("DB_DATABASE")
    dbInstance = os.Getenv("DB_INSTANCE")
    pubSubTopicID = os.Getenv("PUBSUB_TOPIC")
    connectionName = os.Getenv("CLOUDSQL_CONNECTION_NAME")

    // Fetch DB password from Secret Manager (pseudo-code)
    dbPass = fetchSecret(os.Getenv("CLOUDSQL_PASSWD"))

    // Set up CloudSQL connection
    dataSourceName := fmt.Sprintf("%s:%s@unix(/cloudsql/%s)/%s", dbUser, dbPass, connectionName, dbName)
    db, err = sqlx.Open("mysql", dataSourceName)
    if err != nil {
        log.Fatalf("Could not connect to the database: %v", err)
    }
    defer db.Close()

    // Set up Pub/Sub client
    ctx := context.Background()
    projectID := os.Getenv("PROJECT_ID")
    if projectID == "" {
        log.Fatal("Environment variable PROJECT_ID is not set")
    }
    pubSubClient, err = pubsub.NewClient(ctx, projectID)
    if err != nil {
        log.Fatalf("Failed to create PubSub client: %v", err)
    }
    defer pubSubClient.Close()

    pubSubTopic = pubSubClient.Topic(pubSubTopicID)

    // Set up Gin router
    router := gin.Default()
    router.POST("/ingest", handleIngest)
    router.GET("/retrieve", handleRetrieve)

    // Run the server
    if err := router.Run(":8080"); err != nil {
        log.Fatal("Unable to start server: ", err)
    }
}

func fetchSecret(secretName string) string {
    // This function should be implemented to fetch the secret from GCP Secret Manager
    // For the purpose of this example, it will return a placeholder value
    return "your-secret-value"
}

func handleIngest(c *gin.Context) {
    var person Person
    if err := c.ShouldBindJSON(&person); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Insert into CloudSQL
    _, err := db.Exec(insertSQL, person.ID, person.Name, person.LastName, person.FieldA, person.FieldB, person.FieldC)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to insert data into database"})
        return
    }

    // Publish to Pub/Sub
    personBytes, err := json.Marshal(person)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal data"})
        return
    }
    result := pubSubTopic.Publish(context.Background(), &pubsub.Message{Data: personBytes})

    // Block until the result is returned and a server-generated ID is returned for the published message
    _, err = result.Get(context.Background())
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to publish to Pub/Sub"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "Data ingested successfully"})
}

func handleRetrieve(c *gin.Context) {
    field := c.Query("field")
    criteria := c.Query("criteria")

    if field == "" || criteria == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Missing field or criteria parameters"})
        return
    }

    // Perform a search in the database
    var results []Person
    query := fmt.Sprintf("SELECT * FROM lc_table WHERE %s = ?", field)
    err := db.Select(&results, query, criteria)
    if err != nil {
        if err == sql.ErrNoRows {
            c.JSON(http.StatusOK, gin.H{"message": "No data found"})
        } else {
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Error during database query"})
        }
        return
    }

    c.JSON(http.StatusOK, gin.H{"data": results})
}