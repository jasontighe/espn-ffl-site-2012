-- Database creation script for ESPN FFL
-- WARNING: Running this script will destroy an otherwise healthy database.
-- USE WITH CAUTION!

DROP DATABASE IF EXISTS ffl;
CREATE DATABASE ffl;
USE ffl;

-- league inviter
CREATE TABLE leagueinviter(
  leagueinviter_id  BIGINT UNSIGNED NOT NULL auto_increment,
  league_id  BIGINT UNSIGNED NOT NULL,
  user_profile_id  BIGINT UNSIGNED NOT NULL,
  league_name  VARCHAR(32) NOT NULL,
  league_manager_name VARCHAR(150) NOT NULL,
  webcam_count CHAR(1) NOT NULL DEFAULT "0",
  youtube_url  VARCHAR(160) NULL,
  youtube_id  VARCHAR(16) NULL,
  s3_url  TEXT NULL,
  status  VARCHAR(7) NOT NULL DEFAULT "NEW",
  moderation_status  CHAR(1) NULL,
  youtube_public  CHAR(1) NULL,
  youtube_bucket_id  INT UNSIGNED NULL,
  video_type CHAR(1) NOT NULL,
  date_created  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_video_created  TIMESTAMP NULL,
  
  PRIMARY KEY (leagueinviter_id),
  INDEX (league_id)
) ENGINE=InnoDB;

CREATE TABLE leagueinviter_media(
  leagueinviter_media_id  INT UNSIGNED NOT NULL auto_increment,
  league_id  BIGINT UNSIGNED NOT NULL,
  media_id  BIGINT UNSIGNED NULL,
  media_type VARCHAR(24) NULL,
  media_length TINYINT NULL,
  url  TEXT NULL,
  date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (leagueinviter_media_id),
  INDEX (league_id),
  FOREIGN KEY (league_id) REFERENCES leagueinviter(league_id)
) ENGINE=InnoDB;

CREATE TABLE leagueinviter_reject(
  leagueinviter_reject_id  INT UNSIGNED NOT NULL auto_increment,  
  league_id  BIGINT UNSIGNED NOT NULL,
  league_name  VARCHAR(32) NOT NULL,
  league_manager_name VARCHAR(150) NOT NULL,
  thumb_filename TEXT NULL,
  s3_url  TEXT NULL,
  
  PRIMARY KEY (leagueinviter_reject_id)
  
) ENGINE=InnoDB;

CREATE TABLE youtube_bucket(
  youtube_bucket_id  INT UNSIGNED NOT NULL auto_increment,
  num_videos BIGINT UNSIGNED NOT NULL,
  date_last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (youtube_bucket_id)
);

INSERT INTO youtube_bucket (num_videos) VALUES (0);
INSERT INTO youtube_bucket (num_videos) VALUES (0);
INSERT INTO youtube_bucket (num_videos) VALUES (0);
INSERT INTO youtube_bucket (num_videos) VALUES (0);

CREATE TABLE critical_error(
  critical_error_id  INT UNSIGNED NOT NULL auto_increment,
  league_id  BIGINT UNSIGNED NULL,
  message TEXT NULL,
  date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (critical_error_id)
);

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


DROP DATABASE IF EXISTS staging_ffl;
CREATE DATABASE staging_ffl;
USE staging_ffl;

-- league inviter
CREATE TABLE leagueinviter(
  leagueinviter_id  BIGINT UNSIGNED NOT NULL auto_increment,
  league_id  BIGINT UNSIGNED NOT NULL,
  user_profile_id  BIGINT UNSIGNED NOT NULL,
  league_name  VARCHAR(32) NOT NULL,
  league_manager_name VARCHAR(150) NOT NULL,
  webcam_count CHAR(1) NOT NULL DEFAULT "0",
  youtube_url  VARCHAR(160) NULL,
  s3_url  TEXT NULL,
  status  VARCHAR(7) NOT NULL DEFAULT "NEW",
  moderation_status  CHAR(1) NULL,
  youtube_public  CHAR(1) NULL,
  youtube_bucket  INT UNSIGNED NULL,
  video_type CHAR(1) NOT NULL,
  date_created  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_video_created  TIMESTAMP NULL,
  
  PRIMARY KEY (leagueinviter_id),
  INDEX (league_id)
) ENGINE=InnoDB;

CREATE TABLE leagueinviter_media(
  leagueinviter_media_id  INT UNSIGNED NOT NULL auto_increment,
  league_id  BIGINT UNSIGNED NOT NULL,
  media_id  BIGINT UNSIGNED NULL,
  media_type VARCHAR(24) NULL,
  media_length TINYINT NULL,
  url  TEXT NULL,
  date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  PRIMARY KEY (leagueinviter_media_id),
  INDEX (league_id),
  FOREIGN KEY (league_id) REFERENCES leagueinviter(league_id)
) ENGINE=InnoDB;

CREATE TABLE leagueinviter_reject(
  leagueinviter_reject_id  INT UNSIGNED NOT NULL auto_increment,  
  league_id  BIGINT UNSIGNED NOT NULL,
  league_name  VARCHAR(32) NOT NULL,
  league_manager_name VARCHAR(150) NOT NULL,
  thumb_filename TEXT NULL,
  s3_url  TEXT NULL,
  
  PRIMARY KEY (leagueinviter_reject_id)
  
) ENGINE=InnoDB;

CREATE TABLE youtube_bucket(
  youtube_bucket_id  INT UNSIGNED NOT NULL auto_increment,
  username  VARCHAR(32) NOT NULL,
  num_videos BIGINT UNSIGNED NOT NULL,
  
  PRIMARY KEY (youtube_bucket_id)
);

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

grant usage on *.* to ffl_staging@localhost identified by 'ffl_staging';
grant all privileges on ffl_staging.* to ffl_staging@localhost;
