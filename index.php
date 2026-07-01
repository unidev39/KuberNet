<?php
// Secure code: No passwords or hardcoded usernames here
$host = getenv('DB_HOST') ?: 'mysql-db';
$user = getenv('DB_USER');
$pass = getenv('DB_PASSWORD');
$db   = getenv('DB_NAME');

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo "<h1>Connected successfully to the database!</h1>";
echo "<h3>Tables in database:</h3>";

$result = $conn->query("SHOW TABLES");
if ($result->num_rows > 0) {
    echo "<ul>";
    while($row = $result->fetch_array()) {
        echo "<li>" . $row[0] . "</li>";
    }
    echo "</ul>";
} else {
    echo "No tables found. (Database is empty)";
}
$conn->close();
?>
