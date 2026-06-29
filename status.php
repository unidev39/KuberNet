<?php
$host = 'mysql-db';
$user = 'db_user';
$pass = 'db_password'; 
$db   = 'sample_db';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    header("HTTP/1.1 500 Internal Server Error");
    echo "DATABASE UNHEALTHY - Host: " . $host;
} else {
    echo "DATABASE HEALTHY - Host: " . $host;
    $conn->close();
}
?>
