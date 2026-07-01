<?php
$host = getenv('DB_HOST') ?: 'mysql-db';
$user = getenv('DB_USER');
$pass = getenv('DB_PASSWORD');
$db   = getenv('DB_NAME');

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    header("HTTP/1.1 500 Internal Server Error");
    echo "DATABASE UNHEALTHY - Host: " . $host;
} else {
    echo "DATABASE HEALTHY - Host: " . $host;
    $conn->close();
}
?>
