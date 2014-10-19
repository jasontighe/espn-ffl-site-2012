-- Database creation script for ESPN FFL
-- WARNING: Running this script will destroy an otherwise healthy database.
-- USE WITH CAUTION!

DROP DATABASE IF EXISTS ffl;
CREATE DATABASE ffl;
USE ffl;

-- league inviter
CREATE TABLE leagueinviter(
  leagueinviter_id  INT UNSIGNED NOT NULL auto_increment,
  league_id  INT UNSIGNED NOT NULL,
  league_name  VARCHAR(32) NOT NULL,
  league_manager_name VARCHAR(150) NOT NULL,
  webcam_count CHAR(1) NOT NULL DEFAULT "0",
  youtube_url  VARCHAR(160) NULL,
  s3_url  TEXT NULL,
  status  VARCHAR(7) NOT NULL DEFAULT "NEW",
  
  PRIMARY KEY (leagueinviter_id),
  INDEX (league_id)
) ENGINE=InnoDB;

CREATE TABLE leagueinviter_media(
  leagueinviter_media_id  INT UNSIGNED NOT NULL auto_increment,
  league_id  INT UNSIGNED NOT NULL,
  media_id  INT UNSIGNED NULL,
  media_type VARCHAR(24) NULL,
  media_length TINYINT NULL,
  url  TEXT NULL,
  
  PRIMARY KEY (leagueinviter_media_id),
  INDEX (league_id),
  FOREIGN KEY (league_id) REFERENCES leagueinviter(league_id)
) ENGINE=InnoDB;

-- fb mapping
CREATE TABLE fbmap(
  fbmap_id  INT UNSIGNED NOT NULL auto_increment,
  league_id  BIGINT UNSIGNED NOT NULL,
  facebook_id  BIGINT UNSIGNED NOT NULL,
  string  TEXT NOT NULL,

  PRIMARY KEY (fbmap_id),
  INDEX (league_id),
  INDEX (facebook_id)

);

grant usage on *.* to ffl@localhost identified by 'ffl';
grant all privileges on ffl.* to ffl@localhost;
