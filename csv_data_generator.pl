#!/usr/bin/perl

# tips
# export LD_LIBRARY_PATH="/home/shiva/bug/port/altertab/mysql/bld/install/lib/"

# if you get failed: Authentication plugin mysql/plugin/caching_sha2_password.so error then use this alter statement
# ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'insT4Win#';
# FLUSH PRIVILEGES;

# CREATE TABLE emp(
#  empno BIGINT PRIMARY KEY AUTO_INCREMENT,
#  first_name VARCHAR(30) NOT NULL,
#  last_name VARCHAR(30) NOT NULL,
#  sex CHAR(1),
#  phone_no CHAR(10),
#  dob date,
#  hiredate date,
#  job VARCHAR(30),
#  dept CHAR(2),
#  salary DECIMAL(9,2),
#  bonus DECIMAL(9,2),
#  comm DECIMAL(9,2)
# );


use strict;
use warnings;
use DBI;
use Getopt::Long;
use Data::Dumper qw(Dumper);
use Cwd qw(abs_path);
use File::Basename qw(dirname basename);
use File::Spec::Functions qw(splitpath);

my $abs_path = abs_path($0);
my ($vol, $dir, $file) = splitpath($abs_path);
print "\n";
print "*******************************************************\n";
print "************ generating csv file for table ************\n";
print "*******************************************************\n";

my $debug;
my $host;
my $port;
my $user;
my $password;
my $database;
my $tabname;
my $rows;
my $start;
my $datafile;

GetOptions( "debug=s" => \$debug,
            "host=s" => \$host,
            "port=s" => \$port,
            "user=s" => \$user,
            "password=s" => \$password,
            "database=s" => \$database,
            "tabname=s" => \$tabname,
            "rows=s" => \$rows,
            "start=s" => \$start,
            "datafile=s" => \$datafile,
             );
#or die "Usage: perl p2.pl --debug 1 --host 127.0.0.1 --port 3304 --user root --password \"\" --database gator --tabname t1 --rows 2 --start 21 --datafile data1.csv\n";

unless (defined $debug)
{
    usage();
}
unless (defined $host)
{
    usage();
}
unless (defined $port)
{
    usage();
}
unless (defined $user)
{
    usage();
}
unless (defined $password)
{
    usage();
}
unless (defined $database)
{
    usage();
}
unless (defined $tabname)
{
    usage();
}
unless (defined $rows)
{
    usage();
}
unless (defined $start)
{
    usage();
}
unless (defined $datafile)
{
    usage();
}

print "dir = $dir\n";
$datafile = $dir . $datafile;
print "file = $datafile\n";

my @drivers = DBI->available_drivers;
print "DBI available drivers\n";
print join(", ", @drivers),"\n";
print "\n";


#my $dsn = "dbi:mysql:host=127.0.0.1:port=3304:user=root:password=:database=test";
# added ssl support
my $dsn = "dbi:mysql" . ":host=" . $host . ":port=" . $port . ":user=" . $user . ":password=" . $password . ":database=" . $database . ":mysql_ssl_verify_server_cert=0";
print "dsn = $dsn\n";

# connect to MySQL database
my $dbh = DBI->connect($dsn) or die $DBI::errstr;
print "\n";

#my $sql = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, COLUMN_TYPE, EXTRA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'test' AND TABLE_NAME = 't1' order by ORDINAL_POSITION";
my $sql = "SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, EXTRA FROM INFORMATION_SCHEMA.COLUMNS " .
          "WHERE TABLE_SCHEMA = " . "'". $database . "'" . " AND TABLE_NAME = " . "'" . $tabname . "'" . " ORDER BY ORDINAL_POSITION;" ;
print "sql = $sql\n\n";

my $sth = $dbh->prepare($sql);
if (! $sth) {
        die(sprintf('[FATAL] Could not prepare statement: %s\n\n ERRSTR: %s\n', $sth, $dbh->errstr()));
}

my $do_nothing;
my $colname_list="";
my $value_list="";


my $rv = $sth->execute();
if (! $rv) {
    die(sprintf('[FATAL] Could not execute statement: %s\n\n  ERRSTR: %s\n', $sth, $sth->errstr()));
}

# store the table in 2 dimentional array matrix , and disconnect
my @matrix;
my $ct=0;
while(my @row = $sth->fetchrow_array()) {
    ($matrix[$ct][0],$matrix[$ct][1],$matrix[$ct][2],$matrix[$ct][3]) = ($row[0],$row[1],$row[2],$row[3]);
    $ct++;
}

if( $debug == 1)
{
  print Dumper \@matrix;
  
  print "print table structure\n";
  print "=====================\n";
  for ( my $loop=0; $loop<$ct; $loop++)
  {
    print "$matrix[$loop][0],$matrix[$loop][1],$matrix[$loop][2],$matrix[$loop][3]\n";
  }
}

# mysql> SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, COLUMN_TYPE, EXTRA FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'gator' AND TABLE_NAME = 't2' ORDER BY #  # 
# ORDINAL_POSITION;

# +------------------+-----------+--------------------------+---------------+----------------+
# | COLUMN_NAME      | DATA_TYPE | CHARACTER_MAXIMUM_LENGTH | COLUMN_TYPE   | EXTRA          |
# +------------------+-----------+--------------------------+---------------+----------------+
# | col_smallint     | smallint  |                     NULL | smallint      |                |
# | col_int          | int       |                     NULL | int           |                |
# | col_char_255     | char      |                      255 | char(255)     |                |
# | col_datetime_6   | datetime  |                     NULL | datetime(6)   |                |
# | col_bigint       | bigint    |                     NULL | bigint        |                |
# | col_date         | date      |                     NULL | date          |                |
# | pk               | int       |                     NULL | int           | auto_increment |
# | col_char_10      | char      |                       10 | char(10)      |                |
# | col_datetime_3   | datetime  |                     NULL | datetime(3)   |                |
# | col_datetime     | datetime  |                     NULL | datetime      |                |
# | col_tinyint      | tinyint   |                     NULL | tinyint       |                |
# | col_varchar_10   | varchar   |                       10 | varchar(10)   |                |
# | col_decimal_10_5 | decimal   |                     NULL | decimal(10,5) |                |
# | col_varchar_500  | varchar   |                      500 | varchar(500)  |                |
# +------------------+-----------+--------------------------+---------------+----------------+
# 14 rows in set (0.00 sec)


# disconnect from the MySQL database
$sth->finish();
$dbh->disconnect();


# store the rows in data.csv file
open(my $fh, '>', $datafile);

my $row_count=$rows;
my $start_with=$start;

for(my $i=1; $i<=$row_count; $i++)
{

    # if we are generating data for employee table
    # then decide the sex initially.
    # $sex , 0 = male, 1 = female
    my $sex = int(rand(10)) % 2 ;
    # first check for male
    # $sex = 0;
    
    
    for ( my $loop=0; $loop<$ct; $loop++) 
    {
        my ($colname,$datatype,$coltype,$extra) = ($matrix[$loop][0],$matrix[$loop][1],$matrix[$loop][2],$matrix[$loop][3]);

        if ( $extra eq "auto_increment" )
        {
            $do_nothing=0;
            $value_list = $value_list . $start_with . ',';
        }
        elsif ( $extra eq "VIRTUAL GENERATED")
        {
            $do_nothing=0;
        }
        elsif ( $extra eq "STORED GENERATED")
        {
            $do_nothing=0;
        }
        elsif ( $extra eq "INVISIBLE")
        {
            $do_nothing=0;
        }
        else
        {
            $colname_list = $colname_list . $colname . ',';

            if ( $datatype eq "tinyint" )
            {
                $value_list = $value_list . '"' . random_number(1,127) . '"' . ',';
            }
            elsif  ( $datatype eq "smallint" )
            {
                $value_list = $value_list . '"' . random_number(1,32767) . '"' . ',';
            }
            elsif  ( $datatype eq "mediumint" )
            {
                $value_list = $value_list . '"' . random_number(1,8388607) . '"' . ',';
            }
            elsif  ( $datatype eq "int" )
            {
                $value_list = $value_list . '"' . random_number(1,2147483647) . '"' . ',';
            }
            elsif  ( $datatype eq "bigint" )
            {
                $value_list = $value_list . '"' . random_number(1,2147483647) . '"' . ',';
            }
            elsif  ( $datatype eq "bit" )
            {
                $value_list = $value_list . '"' . random_number(0,512) . '"' . ',';
            }

            elsif  ( $datatype eq "decimal" )
            {
                # decimal(10,5) , extract 10,5 and split it
                my ($decimal_value) = $coltype =~ m/\d+,\d+/g;
                my ($precision, $decimal_point) = split(',',$decimal_value, 2);
                #$value_list = $value_list . random_real_number(1,32767) . ',';
                #$value_list = $value_list . random_number(1,32767) . ',';
                $value_list = $value_list . '"' . decimal_number($precision, $decimal_point) . '"' . ',';
            }

            elsif  ( $datatype eq "float" )
            {
                #$value_list = $value_list . random_real_number(1,32767) . ',';
                #$value_list = $value_list . random_number(1,32767) . ',';
                $value_list = $value_list . '"' . decimal_number(10,4) . '"' . ',';
            }

            elsif  ( $datatype eq "double" )
            {
                #$value_list = $value_list . random_real_number(1,32767) . ',';
                #$value_list = $value_list . random_number(1,32767) . ',';
                $value_list = $value_list . '"' . decimal_number(14,6) . '"' . ',';
            }

            elsif  ( ($datatype eq "char") or ($datatype eq "varchar") )
            {
                if ( ($colname =~ /first_name/) or ($colname =~ /last_name/) )
                {
                    # male name
                    if ( $sex == 0 )
                    {
                        $value_list = $value_list . '"' . random_male_name() . '"' . ',';    
                    }
                    # female names
                    elsif ( $sex == 1 )
                    {
                        $value_list = $value_list . '"' . random_female_name() . '"' . ',';    
                    }
                }
                elsif ( $colname eq "sex" )
                {
                    if ($sex == 0)
                    {
                        $value_list = $value_list . '"' . 'M' . '"' . ',';
                    }
                    elsif ($sex == 1)
                    {
                        $value_list = $value_list . '"' . 'F' . '"' . ',';
                    }
                }
                elsif ( $colname =~ /phone_no/ )
                {
                    my ($char_value) = $coltype =~ m/\d+/g;
                    $value_list = $value_list . '"' . random_numeric_string($char_value) . '"' . ',';
                }
                elsif ( $colname =~ /job/ )
                {
                    my ($char_value) = $coltype =~ m/\d+/g;
                    $value_list = $value_list . '"' . random_job_name() . '"' . ',';
                }
                
                elsif ( $colname =~ /country/ )
                {
                    my ($char_value) = $coltype =~ m/\d+/g;
                    $value_list = $value_list . '"' . random_country_name() . '"' . ',';
                }
                
                
                elsif ( $colname =~ /dept/ )
                {
                    my ($char_value) = $coltype =~ m/\d+/g;
                    $value_list = $value_list . '"' . random_numeric_string($char_value) . '"' . ',';
                }
                else
                {
                    # char(255) , extract 255
                    my ($char_value) = $coltype =~ m/\d+/g;
                    $value_list = $value_list . '"' . random_string($char_value) . '"' . ',';
                }
            }
            elsif  ( $datatype eq "binary" )
            {
                $value_list = $value_list . '"' . random_string(100) . '"' . ',';
            }
            elsif  ( $datatype eq "varbinary" )
            {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "text" ) {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "tinytext" ) {
                $value_list = $value_list . '"' . random_string(50) . '"' . ',';
            }
            elsif  ( $datatype eq "mediumtext" ) {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "longtext" ) {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "blob" ) {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "tinyblob" ) {
                $value_list = $value_list . '"' . random_string(40) . '"' . ',';
            }
            elsif  ( $datatype eq "mediumblob" ) {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "longblob" ) {
                $value_list = $value_list . '"' . random_string(500) . '"' . ',';
            }
            elsif  ( $datatype eq "date" ) {
                $value_list = $value_list . '"' . random_date() . '"' . ',';
            }
            elsif  ( $datatype eq "datetime" ) {
                $value_list = $value_list . '"' . random_datetime() . '"' . ',';
            }
            elsif  ( $datatype eq "timestamp" ) {
                $value_list = $value_list . '"' . random_timestamp() . '"' . ',';
            }
            elsif  ( $datatype eq "time" ) {
                $value_list = $value_list . '"' . random_time() . '"' . ',';
            }
            elsif  ( $datatype eq "year" ) {
                $value_list = $value_list . '"' . random_year() . '"' . ',';
            }
            elsif  ( $datatype eq "json" ) {
                $value_list = $value_list . '"' . random_json() . '"' . ',';
            }
        }
    }

    #print "colname_list = $colname_list\n";
    #print "value_list = $value_list\n";
    chop($value_list);
    #print "value_list = $value_list\n";
    print $fh $value_list . "\n";
    $colname_list="";
    $value_list="";
    
    # increment the PK value
    $start_with = $start_with + 1;
}

close $fh;

print "\n";
print "datafile generated successfully\n\n";
display_filesize_str($datafile);
print "\n";

sub usage{
    print "missing options\n";
    die("Usage: perl $file --debug 1 --host 127.0.0.1 --port 3304 --user root --password \"\" --database gator --tabname t1 --rows 2 --start 21 --datafile data1.csv\n");
}


sub random_json{
    # out = "{ ""skills"": [{""skill_name"" : ""AI"", ""exp"" : ""19""}] }"

    my $random_string = '{ ""skills"": [';
    my $no_skills = int(rand(2)) + 1;
    for(my $i = 1; $i <= $no_skills; $i++)
    {
        $random_string .= '{' . '""skill_name"" : ' . '""' . random_skill() . '"", ' . '""exp"" : ' . '""' . int(rand(20)) . '""' .  '},' ;  
    }
    chop($random_string);
    $random_string .= '] }' ;
    return $random_string;
}


sub random_string{
    my $length_of_randomstring = shift;
    my @chars=('a'..'z','A'..'Z','0'..'9');
    my $random_string;
    for(my $i = 0; $i < $length_of_randomstring; $i++)
    {
        $random_string .= $chars[int(rand @chars)];
    }
    return $random_string;
}


sub random_skill{
    my @Skills = ("Python", "Java", "JavaScript", "C++", "Excel", "SQL", "R", "Tableau", "Power BI", "Machine Learning" ,
    "AI", "Cybersecurity", "AWS", "Azure", "Google Cloud", "HTML", "CSS", "React", "Nodejs", "Swift", "Kotlin", "Flutter",
    "Docker", "Kubernetes", "Jenkins", "AutoCAD", "SolidWorks", "Blender", "MySQL", "MongoDB", "PostgreSQL");
    my $random_string = $Skills[rand @Skills];
    return $random_string;
}

sub random_male_name{
    my @Indian_Male_Name = ("Aabha","Aabharan","Aabheer","Aabher","Aadarsh","Aadesh","Aadhishankar","Aadhunik","Aadi","Aadinath",
    "Aaditey","Aafreen","Aagney","Aahlaad","Aahlaadith","Aahwaanith","Aakanksh","Aakar","Aakash","Aalam","Aalap","Aalok",
    "Aamod","Aandaleeb","Aashish","Aatish","Abhay","Abhayananda","Abhayaprada","Abheek","Abhibhava","Abhichandra","Abhidi",
    "Abhihita","Abhijat","Abhijaya","Abhijit","Abhijvala","Abhilash","Abhimand","Abhimani","Abhimanyu","Abhimanyusuta",
    "Abhimoda","Abhinabhas","Abhinanda","Abhinandana","Abhinatha","Abhinav","Abhinava","Abhirup","Abhishek","Abhisoka",
    "Abhisumat","Abhisyanta","Abhivira","Abhra","Abhrakasin","Abhyagni","Abhyudaya","Abhyudita","Abjayoni","Abjit","Acaryatanaya",
    "Achal","Achalapati","Achalendra","Achalesvara","Achanda","Acharya","Acharyanandana","Acharyasuta","Achindra","Achintya",
    "Achyut","Achyuta","Achyutaraya","Adalarasu","Adarsh","Adesh","Adhik","Adhikara","Adhipa","Adhita","Adikavi","Adil",
    "Adinath","Adit","Aditeya","Aditya","Adityanandana","Adityavardhana","Adripathi","Adwaita","Adway","Aftab","Agasti","Agha",
    "Agharna","Aghat","Agneya","Agnikumara","Agniprava","Agrim","Agriya","Ahsan","Aijaz","Aiman","Ainesh","Ajamil","Ajatashatru",
    "Ajay","Ajeet","Ajendra","Ajinkya","Ajit","Ajitabh","Ajitesh","Ajmal","Akalmash","Akash","Akbar","Akhil","Akhilesh","Akmal",
    "Akram","Akroor","Akshan","Akshar","Akshat","Akshath","Akshay","Akshit","Akul","Alagan","Alagarasu","Alam","Alamgir","Aleem",
    "Alhad","Ali","Alok","Aloke","Amaanath","Amal","Amalendu","Amalesh","Amanda","Amar","Amartya","Ambar","Ambarish","Amber","Ambuj",
    "Ameya","Amil","Amin","Amish","Amit","Amitabh","Amitava","Amitbikram","Amitesh","Amitiyoti","Amitrasudan","Amiya","Amlan",
    "Amlankusum","Ammar","Amod","Amogh","Amoha","Amoha","Amol","Amolik","Amrit","Amulya","Anadi","Anal","Anamitra","Anand","Ananga",
    "Ananmaya","Anant","Anantram","Anarghya","Anbarasu","Anbu","Anbuchelvan","Anbumadi","Anbuselvan","Angad","Angada","Angamuthu","Anil",
    "Animish","Anirudh","Anirudhha","Anirvan","Anisa","Anish","Aniteja","Anjasa","Anjum","Anjuman","Ankit","Ankur","Ankush","Anmol","Anoop",
    "Anshu","Anshul","Anshuman","Anshumat","Anugya","Anuha","Anuj","Anunay","Anup","Anupam","Anuraag","Anurag","Anuttam","Anwar","Apoorva",
    "Apparajito","Apurva","Arav","Aravali","Archan","Archit","Ardhendu","Arghya","Arihant","Arijit","Arindam","Arivalagan","Arivali",
    "Arivarasu","Arivoli","Arivuchelvan","Arivumadhi","Arivunambi","Arjit","Arjun","Arjun","Arka","Arnav","Arnesh","Arokya","Aroon",
    "Arshad","Arul","Arulchelvan","Arulselvan","Arumugan","Arun","Aruni","Arvind","Arvinda","Arya","Aryaman","Aryan","Asao","Aseem",
    "Asgar","Ashis","Ashok","Ashraf","Ashu","Ashutosh","Ashwatthama","Ashwin","Asija","Asim","Asit","Aslam","Aslesh","Atal","Atanu",
    "Atharvan","Athiya","Atma","Atmaja","Atmajyoti","Atmananda","Atralarasu","Atre","Atul Atulya",
    "Avadhesh","Avanindra","Avanish","Avatar","Avikshit","Avinash","Avkash","Ayog","Ayush","Ayyappa","Azeez","Azhar","Azzam",
    "Badal","Badri","Badrinath","Badriprasad","Bahubali","Bahuleya","Bajrang","Balaaditya","Balachandra","Balagopal","Balagovind",
    "Balaji","Balakrishna","Balamani","Balamohan","Balaram","Balbir","Baldev","Balram","Balvindra","Balwant","Banbihari","Bandhu",
    "Bandhul","Bankebihari","Bankim","Bankimchandra","Bansi","Bansilal","Barid","Baridbaran","Barindra","Barun","Basanta","Bashir",
    "Basistha","Basudha","Bhadrak","Bhadraksh","Bhagirath","Bhagwant","Bhagyaraj","Bhairav","Bhajan","Bhanu","Bhanu","Bhanudas","Bhanuprasad",
    "Bharadwaj","Bharat","Bhargava","Bhaskar","Bhaskar","Bhaumik","Bhavesh","Bhim","Bhishma","Bhooshan","Bhooshit","Bhrij","Bhudev","Bhupen",
    "Bhupendra","Bhushan","Bhuvan","Bhuvanesh","Bibek","Bibhas","Bibhavasu","Bikram","Bilva","Bimal","Bindusar","Bipin","Bitasok","Bodhan",
    "Boudhayan","Brahmabrata","Brahmadutt","Bratindra","Brijesh","Brijmohan","Buddhadev","Buddhadeva","Budhil","Chaitanya","Chakor","Chakrapani",
    "Chakshu","Chaman","Chamanlal","Champak","Chanchal","Chandak","Chandan","Chandra","Chandrachur","Chandrahas","Chandrak","Chandrakanta",
    "Chandrakishore","Chandrakumar","Chandramohan","Chandran","Chandranath","Chandraraj","Chandrashekhar","Chandrashekhar","Chandresh","Chapal",
    "Charan","Charanjit","Charudutta","Chaturbhuj","Chetan","Chetana","Chhandak","Chidambar","Chidananda","Chinmay","Chinmayananda","Chintamani",
    "Chirag","Chiranjeev","Chirantan","Chirayu","Chitrabhanu","Chitraksh","Chitral","Chitrarath","Chitrasen","Chitta","Chittaprasad","Chittaranjan",
    "Chittaswarup","Chittesh","Chudamani","Dabeet","Dakshesh","Daman","Damian","Damodar","Darpak","Darpan","Darshan","Daruka","Dasharath",
    "Dattatreya","Dayanand","Debashis","Debashish","Deenabandhu","Deep","Deepak","Deepan","Deepankar","Deependra","Deependu","Deepesh","Deepit",
    "Deeptanshu","Deeptendu","Deeptiman","Deeptimoy","Dev","Dev Kumar","Devabrata","Devadas","Devadutt","Devajyoti","Devak","Devanand",
    "Devang","Devarsi","Devdas","Devdutta","Devendra","Devesh","Deveshwar","Devilal","Deviprasad","Devnarayan","Devnath","Devraj",
    "Dhananjay","Dhanesh","Dhanraj","Dhansukh","Dhanvant","Dharanidhar","Dharma","Dharmadas","Dharmadev","Dharmanand","Dharmendra",
    "Dharmendu","Dharmesh","Dharmpal","Dharmveer","Dhaval","Dhawal","Dheeman","Dheemant","Dheer","Dheerendra","Dhiraj","Dhiren",
    "Dhirendra","Dhritiman","Dhruv","Dhruva","Dhwani","Dhyanesh","Digamber","Dilawar","Dilip","Dinanath","Dinar","Dindayal","Dinesh",
    "Dinkar","Divakar","Divyanga","Divyendu","Divyesh","Drupad","Dulal","Duranjaya","Durjaya","Dushyanta","Dwaipayan","Dwijaraj",
    "Dwijendra","Dwijesh","Ekalavya","Ekalinga","Ekambar","Ekanath","Ekanga","Eknath","Ekram","Eshwar","Faiyaz","Faiz","Falak","Falguni",
    "Fanibhusan","Fanindra","Fanish","Fanishwar","Faraz","Farhad","Farhat","Farid","Farokh","Fateh","Fatik","Firdaus","Firoz","Gagan",
    "Gaganvihari","Gajanan","Gajanand","Gajendra","Ganapati","Ganaraj","Gandharva","Gandhik","Ganesh","Gangadhar","Gangadutt","Gangesh",
    "Gangeya","Gangol","Gaurang","Gaurav","Gaurinath","Gautam","Geet","Ghanashyam","Giri","Giridari","Giridhar","Giridhar","Girik","Girilal",
    "Girindra","Giriraj","Girish","Gokul","Gopal","Gopan","Gopesh","Gopichand","Gorakh","Gourishankar","Govind","Govinda","Gudakesha",
    "Gulab","Gulfam","Gulzar","Gulzarilal","Gumwant","Gunaratna","Gunjan","Gupil","Gurbachan","Gurcharan","Gurdayal","Gurdeep","Gurmeet",
    "Gurnam","Gurpreet","Gursharan","Guru","Gurudas","Gurudutt","Gyan","Habib","Hafiz","Hamid","Hamir","Hans","Hanuman","Hanumant",
    "Hardik","Harekrishna","Harendra","Haresh","Hari","Haridas","Harigopal","Harihar","Harilal","Harinarayan","Hariom","Hariprasad",
    "Hariram","Harish","Harishankar","Harishchandra","Haritbaran","Harjeet","Harkrishna","Harmendra","Haroon","Harsh","Harsha","Harshad",
    "Harshal","Harshavardhan","Harshit","Harshita","Harshul","Harshvardhan","Hashmat","Hasit","Hassan","Heer","Hem","Hemachandra","Hemadri",
    "Hemamdar","Hemang","Hemanga","Hemant","Hemanta","Hemaraj","Hemendra","Hemendu","Heramba","Himachal","Himadri","Himaghna","Himanshu",
    "Himmat","Himnish","Hiranmay","Hiranya","Hirendra","Hiresh","Hitendra","Hriday","Hridayesh","Hridaynath","Hrishikesh","Hrishikesh",
    "Hussain","Ibhanan","Ibrahim","Idris","Iham","Ihit","Ikshu","Ilesh","Iman","Imaran","Imtiaz","Indeever","Indivar","Indradutt","Indrajeet",
    "Indrajit","Indrakanta","Indraneel","Indubhushan","Induhasan","Indukanta","Indulal","Indushekhar","Inesh","Intekhab","Iqbal","Irfan",
    "Irshaad","Isar","Ishan","Ishrat","Ishwar","Izhar","Jag","Jagadbandu","Jagadeep","Jagadhidh","Jagadish","Jagajeet","Jagajeevan",
    "Jaganmay","Jagannath","Jagat","Jagjeevan","Jagmohan","Jahan","Jaichand","Jaidayal","Jaidev","Jaigopal","Jaikrishna","Jaimini",
    "Jainarayan","Jaipal","Jairaj","Jaisal","Jaisukh","Jaiwant","Jalal","Jalendu","Jalil","Janak","Janamejay","Janardan","Japa","Japendra",
    "Japesh","Jasbeer","Jashan","Jaspal","Jasraj","Jasveer","Jaswant","Jatan","Jatin","Javed","Jawahar","Jayadeep","Jayaditya","Jayant",
    "Jayashekhar","Jaysukh","Jeemutbahan","Jeevan","Jehangir","Jhoomer","Jignesh","Jihan","Jinendra","Jishnu","Jitendra","Jivitesh",
    "Jnyandeep","Jnyaneshwar","Joginder","Jogindra","Jograj","Jugnu","Jusal","Jyotichandra","Jyotiprakash","Jyotiranjan","Jyotirdhar",
    "Jyotirmoy","Kabir","Kailas","Kailash","Kailashchandra","Kailashnath","Kalash","Kalicharan","Kalidas","Kalimohan","Kalipada","Kaliranjan",
    "Kalyan","Kamadev","Kamal","Kamalakar","Kamalapati","Kamalesh","Kamalnayan","Kamlesh","Kamod; Kambod; Kambodi","Kamraj; Kamesh; Kameshwar","Kamran","Kanad",
    "Kanak","Kanan","Kanchan","Kandarpa","Kanha","Kanhaiya","Kantilal","Kantimoy","Kanu","Kanvar","Kanwal","Kanwaljeet",
    "Kanwalkishore","Kapil","Kapish","Karan","Kareem","Karna","Kartar","Kartik","Kartikeya","karunakar","Karunamay","Karunashankar",
    "Kashif","Kashinath","Kashiprasad","Kashyap","Kathir; Kadir","Kausar","Kaushal",
    "Kaushik","Kaustav","Kaustubh","Kavi","Kavi","Kaviraj","Kedar","Kedarnath","Keshav","Ketan","Kevalkishore",
    "Kevalkumar","Keyur","Khadim","Khajit","Khalid","Khazana","Khemchand","Khemprakash","Khushal","Kinshuk","Kiran",
    "Kiranmay","Kirit","Kirtikumar","Kishore","Kishorekumar","Kripal","Krishanu","Krishna","Krishnachandra","Krishnadeva",
    "Krishnakanta","Krishnakumar","Krishnala","Krishnamurari","Krishnamurthy","Krishnaroop","Krishnendu","Kshaunish","Kuber",
    "Kuberchand","Kularanjan","Kulbhushan","Kuldeep","Kumar","Kunal","Kundan","Kundanlal","Kunja","Kunjabihari","Kush","Kushal",
    "Kusumakar","Lagan","Lakshman","Lakshmibanta","Lakshmidhar","Lakshmigopal","Lakshmikanta","Lalit","Lalitaditya","Lalitchandra",
    "Lalitkishore","Lalitkumar","Lalitmohan","Lalitmohan","Lambodar","Lankesh","Latafat","Latif","Lav","Lochan","Lohitaksha",
    "Lokesh","Loknath","Lokprakash","Lokranjan","Madan","Madangopal","Madhav","Madhavdas","Madhu","Madhuk","Madhukanta","Madhukar",
    "Madhup","Madhur","Madhusudan","Madhusudhana","Magan","Mahabahu","Mahabala","Mahadev","Mahaniya","Mahavir","Maheepati",
    "Mahendra","Mahesh","Maheshwar","Mahin","Mahindra","Mahipal","Mahish","Mahmud","Mahtab","Mainak","Maitreya","Makarand",
    "Malay","Manas","Manasi","Manav","Manavendra","Mandar","Mandeep","Mandhatri","Manendra","Mangal","Mangesh","Mani",
    "Manibhushan","Manik","Manindra","Maniram","Manish","Manishankar","Manishankar","Manjeet","Manmatha","Manmohan","Manohar",
    "Manoj","Manoranjan","Manoranjan","Manprasad","Mansukh","Manu","Mardav","Mareechi","Markandeya","Markandeya","Martand",
    "Martanda","Marut","Maruti","Matsendra","Mayank","Mayanka","Mayur","Megh","Megha","Meghashyam","Meghdutt","Meghnad",
    "Mehboob","Mehdi","Mehmood","Mehul","Mihir","Mihir","Milan","Milap","Milind","Milun","Mirza","Misal","Mitesh","Mithil",
    "Mithilesh","Mithun","Mitra","Mitul","Mohajit","Mohak","Mohal","Mohamad","Mohan","Mohin","Mohit","Mohita","Mohnish",
    "Mohul","Monish","Moti","Motilal","Moulik","Mriganka","Mrigankamouli","Mrigankasekhar","Mrigendra","Mrigesh","Mrityunjay",
    "Mubarak","Mudita","Muhamad","Mukesh","Muktananda","Mukul","Mukunda","Mukut","Mulkraj","Mumtaz","Muni","Murad","Murali",
    "Muralidhar","Muralimanohar","Murari","Murarilal","Musheer","Nabarun","Nabendu","Nabhi","Nachiketa","Nadir","Nagendra",
    "Nagesh","Nahusha","Nairit","Naishadh","Nakshatra","Nakul","Nalin","Nalinaksha","Naman","Namdev","Nanak","Nand","Nanda",
    "Nandan","Nandan","Nandi","Naotau","Narahari","Narasimha","Narayan","Narayana","Narendra","Naresh","Narhari","Narmad",
    "Narottam","Narsimha","Nartan","Natesh","Natraj","Natwar","Naval","Navaneet","Naveen","Navin","Navnit","Navrang","Navroz",
    "Nayan","Neel","Neeladri","Neelam","Neelambar","Neelanjan","Neelesh","Neelkanta","Neelkanth","Neelmadhav","Neelmani",
    "Neelotpal","Neeraf","Neeraj","Nibodh","Nidhish","Nigam","Nihal","Nihar","Niket","Nikhat","Nikhil","Nikhilesh","Nikunj",
    "Nikunja","Nilay","Nilesh","Nimai","Nimish","Ninad","Nipun","Nirad","Niraj","Nirajit","Niramay","Niramitra","Niranjan",
    "Nirav","Nirbhay","Nirijhar","Nirmal","Nirmalya","Nirmit","Nirmohi","Nirupam","Nirvan","Nischal","Nishad","Nishanath",
    "Nishant","Nishesh","Nishikanta","Nishit","Nishita","Nishith","Nishok","Nissim","Niteesh","Nitin","Nitish","Nityagopal",
    "Nityanand","Nityananda","Nityasundar","Nivrutti","Nripa","Nripendra","Nripesh","Ojas","Om","Omanand","Omar","Omja",
    "Omkar","Omprakash","Omrao; Umrao","Omswaroop","Oojam","Oorjit","Osman; Usman","Paavan","Padman","Padmanabh",
    "Padmanabha","Padmapati","Palak","Palash","Palashkusum","Palashranjan","Pallab","Pallav","Panchanan","Pandhari",
    "Panduranga","Panini","Pankaj","Pannalal","Parag","Parakram","Param","Paramananda","Paramartha","Paramesh","Paramhansa",
    "Paramjeet","Paranjay","Parantapa","Parashar","Parashuram","Parasmani","Paravasu","Parees","Paresh","Parijat","Pariket",
    "Parikshit","Parindra","Paritosh","Paritosh","Parkash","Parmameshwar","Parnad","Partha","Parthapratim","Parvatinandan",
    "Parvesh","Patakin","Patanjali","Pathik","Pathin","Patralika","Pavak","Pavan","Pavani","Pavanjit","Pavitra","Payas",
    "Payod","Peeyush","Phalguni","Phanindra","Phenil","Pinak","Pinaki","Pirmohammed","Pitambar","Piyush","Piyush","Poojan",
    "Poojit","Poorna","Poornachandra","Prabal","Prabhakar","Prabhakar","Prabhas","Prabhat","Prabhat","Prabhav","Prabir",
    "Prabodh","Prabodhan","Prabuddha","Prachur","Pradeep","Pradnesh","Pradosh","Pradyot","Pradyumna","Praful","Prafulla",
    "Pragun","Prahlad","Prajeet","Prajesh","Prajin","Prajit","Prakash","Prakat","Prakriti","Pralay","Pramath","Pramesh",
    "Pramit","Pramod","Pran","Pranav","Pranay","Pranay","Pranet","Pranit","Pranjal","Pranjivan","Pransukh","Prasad",
    "Prasanna","Prasata","Prasenjit","Prasham","Prashant","Prashanta","Prasoon","Prasun","Pratap","Prateek","Prateep",
    "Prateet","Pratik","Pratiti","Pratosh","Pratul","Praval","Pravar","Praveen","Praver","Pravir","Prayag","Preetish",
    "Prem","Premal","Premanand","Premendra","Pritam","Prithu","Prithvi","Prithviraj","Priya","Priyabrata","Priyaranjan",
    "Pujit","Pukhraj","Pulak","Pulakesh","Pulastya","Pulin","Pulish","Pundarik","Puneet","Punit","Punyabrata","Punyasloka",
    "Purandar","Puranjay","Purnanada","Purnendu","Puru","Purujit","Purumitra","Pururava","Purushottam","Pushkar","Pushpak",
    "Puskara","Pyarelal","Pyaremohan","Quamar","Quasim","Qutub","Radhakanta","Radhakrishna","Radhavallabh","Radheshyam",
    "Radheya","Raghav","Raghavendra","Raghu","Raghunandan","Raghunath","Raghupati","Raghuvir","Rahas","Rahman","Rahul",
    "Raj","Raja","Rajam","Rajan","Rajani","Rajanikant","Rajanikanta","Rajarshi","Rajas","Rajat","Rajatshubhra","Rajdulari",
    "Rajeev","Rajendra","Rajendrakumar","Rajendramohan","Rajesh","Rajesh","Rajit","Rajiv","Rajivlochan","Rajivnayan",
    "Rajkumar","Rajrishi","Rajyeshwar","Rakesh","Raksha","Ram","Ramakanta","Raman","Ramanuja","Ramashray","Ramavatar",
    "Ramchandra","Ramesh","Rameshwar","Ramkishore","Ramkrishna","Ramkumar","Rammohan","Ramnath","Ramprasad","Rampratap",
    "Ramratan","Ramswaroop","Ranajay","Ranajit","Randhir","Rangan","Ranganath","Ranjan","Ranjeet","Ranjit","Rasaraj",
    "Rasbihari","Rasesh","Rashmil","Rasik","Rasul","Ratan","Ratannabha","Rathin","Ratish","Ratnakar","Ratul","Ravi",
    "Ravikiran","Ravinandan","Ravindra","Ravishu","Raza","Razak","Rebanta","Rehman","Rehmat","Riddhiman","Rijul",
    "Ripudaman","Rishabh","Rishi","Rishikesh","Rituparan","Rituraj","Ritvik","Riyaz","Rizvan","Rochak","Rochan",
    "Rohan","Rohanlal","Rohit","Rohitasva","Ronak","Roshan","Ruchir","Rudra","Rujul","Rupak","Rupesh","Rupin","Rushil",
    "Rustom","Rutujit","Sacchidananda","Sachet","Sachetan","Sachin","Sachit","Sadanand","Sadashiva","Sadeepan","Sadiq",
    "Saeed","Sagar","Sagun","Sahaj","Sahas","Sahdev","Sahib","Sahil","Sainath","Saipraasad","Saipratap","Sajal","Sajan",
    "Saket","Salaman","Salarjung","Saleem","Salil","Salim","Samar","Samarendra","Samarendu","Samarjit","Samarth","Sambaran",
    "Sambhav","Sambhddha","Sambit","Sameen","Sameer","Samendra","Samir","Samiran","Sampat","Samrat","Samudra","Samudragupta",
    "Samudrasen","Samyak","Sanabhi","Sanam","Sanat","Sanatan","Sanchay","Sanchit","Sandananda","Sandeep","Sandeepen","Sanjay",
    "Sanjiv","Sanjivan","Sanjog","Sankalpa","Sankara","Sankarshan","Sanket","Sanobar","Santosh","Sanwariya","Sanyog","Sapan",
    "Saquib","Saral","Sarang","Saras","Sarasija","Sarasvat","Sarat","Sarbajit","Sarfaraz","Saroj","Sartaj","Sarthak","Sarup",
    "Sarvadaman","Sarvesh","Sarwar","Sashreek","Satindra","Satish","Satrijit","Satvamohan","Satyajit","Satyakam","Satyaki",
    "Satyamurty","Satyanarayan","Satyankar","Satyaprakash","Satyapriya","Satyasheel","Satyavan","Satyavrat","Satyavrata",
    "Satyendra","Saurabh","Saurav","Savar","Savitendra","Sawan","Sayam","Sayed","Seemanta","Senajit","Sevak","Shaan","Shachin",
    "Shachindra","Shadab","Shaheen","Shahid","Shailendra","Shailesh","Shaistakhan","Shakib","Shaktidhar","Shakunt","Shakyasinha",
    "Shalin","Shambhu","Shameek","Shami","Shamindra","Shams","Shamshu; Shamshad","Shandar","Shankar","Shankha","Shanmuga",
    "Shanmukha","Shantanu","Shantashil","Shantimay","Shantinath","Shantiprakash","Shantipriya","Sharad","Sharadchandra","Sharadindu",
    "Sharan","Sharang","Shardul","Shariq","Shashank","Shashanka","Shashee","Shashibhushan","Shashidhar","Shashikant","Shashikiran",
    "Shashimohan","Shashishekhar","Shashwat","Shatrughan","Shatrughna","Shatrujit","Shatrunjay","Shattesh","Shaukat","Shaunak",
    "Sheetal","Sheil","Shekhar","Shesh","Shevantilal","Shikha","Shikhar","Shirish","Shiromani","Shirshirchandra","Shishir",
    "Shishirkumar","Shishupal","Shiv","Shivendra","Shivendu","Shivesh","Shivlal","Shivraj","Shivshankar","Shobhan","Shoorsen",
    "Shravan","Shravankumar","Shrenik","Shreshta","Shreyas","Shridhar","Shrigopal","Shrihari","Shrikanta","Shrikrishna","Shrikumar",
    "Shrinath","Shrinivas","Shripad","Shripal","Shripati","Shriram","Shriranga","Shrish","Shrivatsa","Shriyans","Shubha",
    "Shubhang","Shubhankar","Shubhashis","Shubhendu","Shubhranshu","Shuddhashil","Shulabh","Shvetang","Shvetank","Shyam",
    "Shyamal","Shyamsundar","Siddhanta","Siddharth","Siddhartha","Siddheshwar","Siraj","Sitakanta","Sitanshu","Sitikantha",
    "Sivanta","Smarajit","Smaran","Smritiman","Snehal","Snehanshn","Snehin","Sohail","Soham","Sohan","Sohil","Som","Somansh",
    "Somendra","Someshwar","Somnath","Sopan","Soumil","Soumyakanti","Sourabh","Sourish","Srijan","Srikant","Srinivas","Sriram",
    "Sual","Subal","Subash","Subbarao","Subhadra","Subhan","Subhash","Subhash","Subinay","Subodh","Subrata","Suchir","Sudama",
    "Sudama","Sudarshan","Sudeep","Sudesh","Sudesha","Sudeva","Sudhakar","Sudhamay","Sudhanshu","Sudhanssu","Sudhi","Sudhindra",
    "Sudhir","Sudhish","Sugata","Sugreev","Sugriva","Suhail","Suhas","Suhrid","Suhrit","Sujan","Sujash","Sujay","Sujit","Sujit",
    "Sukant","Sukanta","Sukesh","Suketu","Sukhamay","Sukhdev","Sukrit","Sukumar","Sulalit","Sulekh","Sulochan","Sultan","Suman",
    "Sumant","Sumanta","Sumantra","Sumeet","Sumit","Sumitra","Sunanda","Sunasi","Sundar","Sundar","Sunil","Sunirmal","Suparna",
    "Suprakash","Supratik","Supratim","Supriya","Sur","Suraj","Surajit","Suranjan","Surdeep","Suren","Suresh","Suresh","Surya",
    "Suryabhan","Suryakant","Suryakanta","Suryashankar","Sushanta","Sushil","Sushobhan","Sushrut","Sushruta","Sutej","Suvan",
    "Suvimal","Suvrata","Suyash","Swagat","Swami","Swaminath","Swapan","Swapnil","Swaraj","Swarup","Swayambhu","Swetaketu",
    "Syamantak","Tahir","Taizeen","Taj","Tajdar","Talat","Talib","Talleen","Tamal","Tamkinat","Tamonash","Tanay","Tanmay",
    "Tanuj","Tanveer","Tapan","Tapas","Tapasendra","Tapasranjan","Tapomay","Tarachand","Tarak","Tarakeshwar","Taraknath",
    "Taral","Taran","Tarang","Taranga","Taraprashad","Tarik","Tariq","Tarit","Tarun","Taruntapan","Tathagata","Tausiq","Teerth",
    "Teerthankar","Tej","Tejas","Tejeshwar","Tejomay","Thakur","Tilak","Timin","Timir","Timirbaran","Tirtha","Titir","Toshan",
    "Trailokva","Trambak","Tribhuvan","Tridib","Trigun","Trilochan","Trilok","Trilokesh","Tripurari","Trishanku","Trivikram",
    "Tufan","Tuhin","Tuhinsurra","Tukaram","Tulasidas","Tulsidas","Tungar","Tungesh","Tushar","Tusharkanti","Tusharsuvra","Tyagraja",
    "Udar","Uday","Udayachal","Udayan","Uddhar","Uddhav","Udeep","Udit","Udyam","Udyan","Ujagar","Ujala","Ujesh","Ujwal","Ulhas",
    "Umakant","Umanand","Umanant","Umang","Umaprasad","Umashankar","Umed","Umesh","Umrao","Unmesh","Unnat","Upagupta","Upamanyu",
    "Upendra","Urjita","Ushakanta","Utanka","Utkarsh","Utkarsha","Utpal","Utsav","Uttam","Uttar","Uttiya","Vachan","Vachaspati",
    "Vaibhav","Vaijnath","Vajra","Vajradhar","Vajramani","Vajrapani","Vallabh","Valmik","Valmiki","Vaman","Vamsi","Vanajit","Vandan",
    "Vaninath","Vardhaman","Varij","Varindra","Varun","Vasant","Vasava","Vasistha","Vasu","Vasudev","Vasudev","Vasuman","Vatsal",
    "Ved","Vedanga","Vedavrata","Vedmohan","Vedprakash","Veer","Veera","Veni","Venimadhav","Vibhas","Vibhat","Vibhishan","Vibhu",
    "Vidur","Vidur","Vidyacharan","Vidyadhar","Vidyaranya","Vidyasagar","Vidyut","Vighnesh; Vignesh","Vihanga","Vijanyendra",
    "Vijay","Vijay","Vijendra","Vikas","Vikesh","Vikram","Vikramaditya","Vikramajit","Vikramendra","Vikrant","Vikranta","Vilas",
    "Vilok","Vilokan","Vimal","Vinay","Vinayak","Vineet","Vinesh","Vinod","Vinod","Vipan","Vipin","Viplab","Viplav","Vipra",
    "Vipul","Vir","Viraj","Viral","Virendra","Viresh","Virochan","Vishal","Vishesh","Vishnu","Vishram","Vishva","Vishvajit",
    "Vishvakarma","Vishvatma","Vishwambhar","Vishwamitra","Vishwanath","Vishwas","Vishwesh","Vismay","Viswanath","Viswas",
    "Vithala","Vitthal","Vivek","Vivekananda","Vrajakishore","Vrajamohan","Vrajanadan","Vrajesh","Vrishin","Vyasa","Vyomesh",
    "Wahab","Wajidali","Wali","Waman","Yaaseen","Yadav","Yadavendra","Yadunandan","Yadunath","Yaduraj","Yaduvir","Yagna",
    "Yahyaa","Yaj","Yajat","Yajnadhar","Yajnarup","Yajnesh","Yamahil","Yamajit","Yaman","Yamir","Yasaar","Yash","Yash","Yashas",
    "Yashodev","Yashodhan","Yashodhara","Yashpal","Yashwant","Yasir","Yatin","Yatindra","Yatish","Yayin","Yazeed","Yogendra",
    "Yogesh","Yogi","Yoonus","Yoosuf","Yudhajit","Yudhisthir","Yudishtra","Yugandhar","Yuvaraj","Yuvraj","Yuyutsu");

    my $random_string = $Indian_Male_Name[rand @Indian_Male_Name];
    return $random_string;
}


sub random_female_name{
    my @Indian_Female_Name = ("Aaarti","Aafreen","Abani","Abha","Abhaya","Abhilasha","Aboil","Achala","Adarsh","Adhira","Adishree","Aditi","Adrika","Aghanashini",
    "Agrata","Agrima","Ahalya","Ahladita","Aishani","Aishwarya","Ajala","Ajanta","Akhila","Akriti","Akshaya","Akshita","Akuti",
    "Alaka","Alaknanda","Alisha","Alka","Almas","Alopa","Alpa","Alpana","Amala","Amba","Ambika","Ambu","Ambuda","Ambuja",
    "Ambuja","Amita","Amla","Amoda","Amodini","Amrapali","Amrita","Amritkala","Amrusha","Amshula","Amulya","Anagha","Anahita",
    "Anala","Anamika","Anandamayi","Anandi","Anandini","Anandita","Ananya","Anarghya","Anasooya","Anasuya","Anchal","Anchita",
    "Angana","Angarika","Anika","Anindita","Anisha","Anita","Anjali","Anjana","Anju","Anjushree","Anjushri","Ankita","Annapurna",
    "Anoushka","Anshula","Antara","Anuhya","Anumati","Anupama","Anuprabha","Anuradha","Anuragini","Anurati","Anusha","Anushka",
    "Anushri","Anuva","Anwesha","Apala","Aparijita","Aparna","Apsara","Apurva","Apoorva","Aradhana","Arati","Archa","Archan",
    "Archana","Archisha","Archita","Arpana","Arpita","Arshia","Aruna","Arundhati","Aruni","Arunima","Asavari","Ascharya",
    "Aseema","Asgari","Asha","Ashakiran","Ashalata","Ashavari","Ashima","Ashis","Ashna","Ashwini","Asita","Aslesha","Asmita",
    "Atasi","Atmaja","Atreyi","Avani","Avantika","Ayesha","Ayushmati","Aziza","Bageshri","Bahula","Baidehi","Baijayanthi",
    "Baisakhi","Baishali","Bakul","Bakula","Bala","Ballari","Banamala","Banani","Bandana","Bandhula","Bandhura","Banhi",
    "Banhishikha","Banita","Bansari","Barnali","Barsha","Baruna","Baruni","Basabi","Basanti","Bela","Beli","Benazir","Bhadra",
    "Bhagirathi","Bhagwanti","Bhagya","Bhagyalakshmi","Bhagyashree","Bhagyawati","Bhairavi","Bhakti","Bhamini","Bhanuja",
    "Bhanumati","Bhanupriya","Bharani","Bharati","Bhargavi","Bhavana","Bhavini","Bhavna","Bhilangana","Bhoomi","Bhoomika",
    "Bhuvana","Bimala","Bina","Binata","Bindiya","Bindu","Binodini","Bipasha","Bishakha","Bratati","Brinda","Bulbul","Bulbuli",
    "Cauvery","Chadna","Chaitali","Chaitaly","Chaitan","Chakori","Chakrika","Chameli","Chameli","Champa","Champabati","Champakali",
    "Chanchala","Chandana","Chandana","Chandani","Chandanika","Chandika","Chandni","Chandrabali","Chandrabhaga","Chandrakala",
    "Chandraki","Chandrakin","Chandraleksha","Chandran i","Chandrika","Chandrima","Changuna","Chapala","Charita","Charu","Charulata",
    "Charulekha","Charumati","Charuprabha","Charusheela","Charvi","Chatura","Chhabi","Chhavvi","Chhaya","Chimayi","Chinmayi",
    "Chintan","Chintana","Chintanika","Chiti","Chitkala","Chitra","Chitragandha","Chitralekha","Chitrali","Chitramala","Chitrangada",
    "Chitrani","Chitrarekha","Chitrita","Daksha","Dakshata","Dakshayani","Damayanti","Damini","Darika","Darpana","Darshana",
    "Darshwana","Daya","Dayamayee","Dayanita","Dayita","Deeba","Deepa","Deepabali","Deepali","Deepamala","Deepanwita","Deepaprabha",
    "Deepashikha","Deepavali","Deepika","Deepta","Deepti","Deeptikana","Deeptimoyee","Devahuti","Devak","Devaki","Devangana",
    "Devasree","Devi","Devika","Devyani","Dhanashri","Dhanishta","Dhanya","Dhanyata","Dhara","Dharani","Dharini","Dharitri","Dhatri",
    "Dhriti","Dhvani","Dhwani","Diksha","Dilber","Dilshad","Disha","Diti","Divya","Doyel","Draupadi","Dristi","Dulari","Durba","Durga",
    "Durva","Dwipavati","Ecchumati","Ekaparana","Ekata","Ekavali","Ekta","Ektaa","Ela","Enakshi","Esha","Eshana","Eshita","Faiza",
    "Fajyaz","Falguni","Farha","Faria","Farida","Fatima","Fawiza","Firoza","Foolan","Foolwati","Fulki","Fullara","Gajagamini","Gajra",
    "Gandhali","Ganga","Gangika","Gangotri","Gargi","Gatita","Gauhar","Gaura","Gauri","Gaurika","Gautami","Gayatri","Gazala","Geena",
    "Geeta","Geeti","Geetika","Girija","Gitanjali","Godavari","Gomati","Gool","Gopa","Gopi","Gopika","Gorochana","Govindi","Gulab",
    "Gunjana","Gunwanti","Gurjari","Gyanada","Habiba","Hafiza","Haimavati","Hamsa","Hanima","Hansa","Hansika","Hansini","Harathi",
    "Harimanti","Harinakshi","Harini","Haripriya","Harita","Harsha","Harsha","Harshada","Harshini","Hasina","Hasita","Hasumati","Heera",
    "Hema","Hemangi","Hemangini","Hemanti","Hemavati","Hemlata","Hena","Hetal","Hima","Himagouri","Himani","Hina","Hindola","Hiral",
    "Hiranmayi","Hirkani","Hita","Hiya","Hoor","Husna","Iha","Ihina","Ikshu","Ila","Ina","Inayat","Indira","Indira","Indrakshi","Indrani",
    "Indrasena","Indrayani","Indu","Induja","Induja","Indukala","Induleksh","Induma","Indumati","Indumukhi","Ipsa","Ipsita","Ira",
    "Iravati","Isha","Ishana","Ishani","Ishika","Ishita","Ishrat","Ishwari","Ivy","Jabeen","Jagadamba","Jagriti","Jahanara","Jaheel",
    "Jahnavi","Jaishree","Jaisudha","Jaiwanti","Jalabala","Jaladhija","Jalaja","Jamini","Jamna","Jamuna","Janaki","Janani","Janhavi",
    "Jasoda","Jasodhara","Jaya","Jayalakshmi","Jayalalita","Jayamala","Jayani","Jayanti","Jayantika","Jayaprada","Jayashree","Jayashri",
    "Jayati","Jayita","Jeeval","Jeevana","Jeevankala","Jeevanlata","Jeevika","Jetashri","Jharna","Jhilmil","Jhinuk","Jigya","Joel",
    "Joshita","Jowaki","Juhi","Jui","Juily","Jyoti","Jyotibala","Jyotika","Jyotirmoyee","Jyotishmati","Jyotsna","Kadambari","Kadambini",
    "Kaishori","Kajal","Kajjali","Kakali","Kala","Kalanidhi","Kalavati","Kalavati","Kali","Kalika","Kalindi","Kalindi","Kallol","Kalpana",
    "Kalpita","Kalyani","Kalyani","Kamakshi","Kamala","Kamalakshi","Kamalika","Kamalini","Kamalkali","Kamana","Kamini","Kamna","Kana",
    "Kanak","Kanaka","Kanakabati","Kanaklata","Kanakpriya","Kanan","Kananbala","Kanchan","Kanchana","Kanchi","Kanika","Kankana","Kanta",
    "Kanti","Kapila","Kapotakshi","Karabi","Karishma","Karuna","Karunamayi","Kashi","Kashmira","Kasturi","Katyayani","Kaumudi","Kaushalya",
    "Kaveri","Kavita","Keertana","Kesar","Kesari","Keshi","Keshika","Keshini","Ketaki","Ketana","Keya","Khyati","Kimaya","Kiran",
    "Kiranmala","Kirtana","Kirti","Kishori","Kokila","Komal","Komala","Koyel","Krandasi","Kranti","Kripa","Krishna","Krishnaa","Krishnakali",
    "Kriti","Krittika","Krupa","Kshama","Kshanika","Kumari","Kumkum","Kumud","Kumudini","Kunda","Kundanika","Kunjal","Kunjalata","Kunjana",
    "Kuntal","Kuntala","Kunti","Kurangi","Kushala","Kusum","Kusuma","Kusumanjali","Kusumavati","Kusumita","Kusumlata","Laabha","Laalamani",
    "Laasya","Labangalata","Laboni","Lajja","Lajjawati","Lajwanti","Lajwati","Laksha","Lakshana","Lakshmi","Lakshmishree","Lakshya","Lalan",
    "Lalana","Lali","Lalima","Lalita","Lalitamohana","Lalitha","Lata","Latakara","Latangi","Latha","Latika","Lavali","Lavanya","Leela",
    "Leelamayee","Leelavati","Leena","Lekha","Lekha","Lily","Lipi","Lipika","Lochan","Lochana","Lola","Lona","Lopa","Lopamudra","Maanasa",
    "Maanika","Madhavi","Madhavilata","Madhu","Madhubala","Madhuchanda","Madhuksara","Madhulata","Madhulekha","Madhulika","Madhumalati",
    "Madhumati","Madhunisha","Madhur","Madhura","Madhuri","Madhurima","Madhushri","Madirakshi","Magana","Mahadevi","Mahagauri","Mahajabeen",
    "Mahalakshmi","Mahamaya","Mahasweta","Mahati","Mahi","Mahijuba","Mahika","Mahima","Mahua","Maina","Maithili","Maitreya","Maitreyi","Maitri",
    "Makshi","Mala","Malashree","Malati","Malavika","Malaya","Malina","Malini","Mallika","Malti","Mamata","Manali","Manana","Manasi","Manda",
    "Mandakini","Mandakranta","Mandaraa","Mandarmalika","Mandira","Mangala","Mangla","Manideepa","Manik","Manikuntala","Manimala","Manimekhala",
    "Manini","Manisha","Manjari","Manjira","Manjistha","Manju","Manjubala","Manjula","Manjulika","Manjusha","Manjushri","Manjusri","Manjyot",
    "Manmayi","Manorama","Manoranjana","Manushri","Marala","Marichi","Marisa","Markandeya","Matangi","Mausumi","Maya","Mayuka","Mayukhi","Mayura",
    "Mayuri","Medha","Medini","Meena","Meenakshi","Meera","Megha","Meghamala","Meghana","Mehal","Mehbooba","Meher","Mehrunissa","Mehul","Mekhala",
    "Mena","Menaka","Minal","Minati","Mirium","Mita","Mitali","Mohana","Mohini","Mohisha","Mridula","Mriganayani","Mrinal","Mrinali","Mrinalini",
    "Mrinalini","Mrinmayi","Mudra","Mudrika","Mugdha","Mukta","Mukti","Mukula","Mukulita","Muniya","Mythili","Mythily","Naaz","Nachni","Nadira",
    "Nagina","Naina","Naiya","Najma","Nalini","Namita","Namrata","Nanda","Nandana","Nandika","Nandini","Nandita","Narayani","Narmada","Narois",
    "Nartan","Naseen","Natun","Nauka","Navaneeta","Naveena","Nayana","Nayantara","Nazima","Neeharika","Neela","Neelabja","Neelakshi","Neelam",
    "Neelanjana","Neelkamal","Neepa","Neeraja","Neeta","Neeti","Neha","Nehal","Netra","Netravati","Nidhi","Nidra","Niharika","Nikhita","Nilasha",
    "Nilaya","Nileen","Nilima","Niloufer","Nina","Nipa","Niral","Niranjana","Nirmala","Nirmayi","Nirupa","Nirupama","Nisha","Nisha","Nishithini",
    "Nishtha","Nishtha","Nita","Niti","Nitya","Nityapriya","Nivedita","Nivedita","Nivritti","Niyati","Noopur","Noor","Noorjehan","Nupura","Nusrat",
    "Nutan","Ojal","Ojaswini","Omana","Padma","Padma","Padmaja","Padmajai","Padmakali","Padmal","Padmalaya","Padmalochana","Padmavati","Padmini",
    "Pakhi","Pakshi","Pallavi","Pallavi","Pallavini","Panchali","Panna","Parama","Parameshwari","Paramita","Parbarti","Pari","Paridhi","Parinita",
    "Parnal","Parnashri","Parni","Parnik","Parnika","Parthivi","Parul","Parvani","Parvati","Parveen","Patmanjari","Patralekha","Pavana","Pavani",
    "Payal","Payal","Payoja","Phiroza","Phoolan","Pia","Piki","Pingala","Pival","Piyali","Pooja","Poonam","Poorbi","Poornima","Poorvi","Poushali",
    "Prabha","Prabhati","Prachi","Pradeepta","Pragati","Pragya","Pragya","Pragyaparamita","Pragyawati","Prama","Pramada","Pramila","Pramiti",
    "Pranati","Prapti","Prarthana","Prashansa","Prashanti","Pratibha","Pratigya","Pratima","Pratishtha","Preeti","Prem","Prema","Premala",
    "Prerana","Preyasi","Prita","Pritha","Priti","Pritika","Pritikana","Pritilata","Priya","Priyadarshini","Priyal","Priyam","Priyamvada",
    "Priyanka","Puja","Pujita","Puloma","Punam","Punarnava","Punita","Punthali","Purnima","Purva","Purvaja","Pushpa","Pushpanjali","Pushpita",
    "Pusti","Putul","Quarrtulain","Quasar","Raakhi","Rabia","Rachana","Rachita","Rachna","Radha","Radhika","Ragini","Rajalakshmi","Rajani",
    "Rajanigandha","Rajata","Rajdulari","Rajeshwari","Rajhans","Rajkumari","Rajnandhini","Rajshri","Raka","Rakhi","Raksha","Rama","Ramani",
    "Ramani","Rambha","Rameshwari","Ramita","Ramya","Rangana","Rani","Ranita","Ranjana","Ranjini","Ranjita","Rashi","Rashmi","Rashmika","Rasika",
    "Rasna","Rati","Ratna","Ratnabala","Ratnabali","Ratnajyouti","Ratnalekha","Ratnali","Ratnamala","Ratnangi","Ratnaprabha","Ratnapriya",
    "Ratnavali","Raviprabha","Rekha","Renu","Renuka","Renuka","Resham","Reshma","Reshmi","Reva","Revati","Richa","Riddhi","Riju","Rijuta",
    "Rishika","Riti","Ritu","Rohini","Roma","Roshan","Roshni","Rubaina","Ruchi","Ruchira","Rudrani","Rudrapriya","Rujuta","Rukma","Rukmini",
    "Ruksana","Ruma","Rupa","Rupali","Rupashi","Rupashri","Sachi","Sachita","Sadaf","Sadgati","Sadguna","Sadhan","Sadhana","Sadhika","Sadhvi",
    "Sadiqua","Saeeda","Safia","Sagarika","Saguna","Saguna","Sahana","Saheli","Sahiba","Sahila","Sai","Sajala","Sajni","Sakhi","Sakina",
    "Salena","Salila","Salima","Salma","Samata","Sameena","Samhita","Samidha","Samiksha","Samit","Samita","Sampada","Sampatti","Sampriti",
    "Sana","Sananda","Sanchali","Sanchaya","Sanchita","Sandhaya","Sandhya","Sangita","Saniya","Sanjana","Sanjivani","Sanjukta","Sanjula",
    "Sanjushree","Sankul","Sannidhi","Sanskriti","Santawana","Santayani","Sanvali","Sanwari","Sanyakta","Sanyukta","Saparna","Saphala",
    "Sapna","Sarada","Sarakshi","Sarala","Sarama","Saranya","Sarasa","Sarasi","Sarasvati","Saraswati","Saravati","Sarayu","Sarbani",
    "Sarika","Sarit","Sarita","Sarjana","Saroj","Saroja","Sarojini","Saruprani","Saryu","Sashi","Sasmita","Sati","Satya","Satyaki",
    "Satyarupa","Satyavati","Saudamini","Saumya","Savarna","Savita","Savitashri","Savitri","Sawini","Sayeeda","Seema","Seemanti","Seemantini",
    "Seerat","Sejal","Selma","Semanti","Serena","Sevati","Sevita","Shabab","Shabalini","Shabana","Shabari","Shabnum","Shachi","Shagufta",
    "Shaheena","Shaila","Shaili","Shakambari","Shakeel","Shakeela","Shakti","Shakuntala","Shalaka","Shalin","Shalini","Shalini","Shalmali",
    "Shama","Shambhavi","Shameena","Shamim","Shamita","Shampa","Shankari","Shankhamala","Shanta","Shantala","Shanti","Sharada","Sharadini",
    "Sharanya","Sharika","Sharmila","Sharmistha","Sharmistha","Sharvani","Sharvari","Shashi","Shashibala","Shashirekha","Shaswati","Shatarupa",
    "Sheela","Sheetal","Shefali","Shefalika","Shejali","Shekhar","Shevanti","Shibani","Shikha","Shilpa","Shilpita","Shinjini","Shipra","Shirin",
    "Shishirkana","Shiuli","Shivangi","Shivani","Shobha","Shobha","Shobhana","Shobhita","Shobhna","Shorashi","Shrabana","Shraddha","Shradhdha",
    "Shravana","Shravani","Shravanti","Shravasti","Shree","Shreela","Shreemayi","Shreeparna","Shreya","Shreyashi","Shri","Shridevi","Shridula",
    "Shrigauri","Shrigeeta","Shrijani","Shrikirti","Shrikumari","Shrilata","Shrilekha","Shrimati","Shrimayi","Shrivalli","Shruti","Shruti",
    "Shubha","Shubhada","Shubhangi","Shubhra","Shuchismita","Shuchita","Shukla","Shukti","Shulka","Shweta","Shyama","Shyamal","Shyamala",
    "Shyamali","Shyamalika","Shyamalima","Shyamangi","Shyamari","Shyamasri","Shyamlata","Shyla","Sibani","Siddheshwari","Siddhi","Siddhima",
    "Sikata","Sikta","Simran","Simrit","Sindhu","Sinsapa","Sita","Sitara","Siya","Smaram","Smita","Smrita","Smriti","Sneh","Sneha","Snehal",
    "Snehalata","Snigdha","Sohalia","Sohni","Soma","Somalakshmi","Somansh","Somatra","Sona","Sonakshi","Sonal","Sonali","Sonia","Sonika",
    "Soorat","Soumya","Sourabhi","Sreedevi","Sridevi","Sristi","Stavita","Stuti","Subarna","Subhadra","Subhaga","Subhagya","Subhashini",
    "Subhuja","Subrata","Suchandra","Sucharita","Sucheta","Suchi","Suchira","Suchita","Suchitra","Sudakshima","Sudarshana","Sudeepa",
    "Sudeepta","Sudeshna","Sudevi","Sudha","Sudhamayi","Sudhira","Sudipta","Sudipti","Sugita","Sugouri","Suhag","Suhaila","Suhasini","Suhina",
    "Suhrita","Sujala","Sujata","Sujaya","Sukanya","Sukeshi","Sukriti","Suksma","Sukumari","Sulabha","Sulakshana","Sulalita","Sulekh",
    "Suloch","Sulochana","Sultana","Sumana","Sumanolata","Sumati","Sumedha","Sumita","Sumitra","Sunanda","Sunandini","Sunandita","Sunayana",
    "Sunayani","Sundari","Sundha","Suneeti","Sunetra","Sunila","Sunita","Suniti","Suparna","Suprabha","Supriti","Supriya","Surabhi",
    "Suraksha","Surama","Suranjana","Suravinda","Surekha","Surina","Surotama","Suruchi","Surupa","Suryakanti","Sushama","Sushanti","Sushila",
    "Sushma","Sushmita","Sushobhana","Susita","Susmita","Sutanuka","Sutapa","Suvarna","Suvarnaprabha","Suvarnarekha","Suvarnmala","Swagata",
    "Swaha","Swapna","Swapnali","Swapnasundari","Swarnalata","Swarupa","Swasti","Swati","Tabassum","Tamali","Tamalika","Tamanna","Tamasa",
    "Tamasi","Tambura","Tanaya","Tanika","Tanima","Tanmaya","Tannishtha","Tanseem","Tanu","Tanuja","Tanuka","Tanushri","Tanushri","Tanvi",
    "Tapani","Tapasi","Tapati","Tapi","Tapti","Tara","Taraka","Tarakeshwari","Tarakini","Tarala","Tarana","Tarangini","Tarannum","Tarika",
    "Tarini","Tarjani","Taru","Tarulata","Taruni","Tarunika","Tarunima","Tatini","Teertha","Teesta","Tehzeeb","Teja","Tejaswi","Tejaswini",
    "Thumri","Tilaka","Tilottama","Timila","Titiksha","Toral","Tridhara","Triguna","Triguni","Trikaya","Trilochana","Trinayani","Trinetra",
    "Triparna","Tripta","Tripti","Tripurasundari","Tripuri","Trisha","Trishala","Trishna","Triveni","Triyama","Trupti","Trusha","Tuhina",
    "Tulasi","Tulika","Tusharkana","Tusti","Udaya","Udita","Uditi","Ujas","Ujjala","Ujjanini","Ujjwala","Ujwala","Ulka","Ulupi","Uma","Uma",
    "Umika","Umrao","Unnati","Upala","Upama","Upasana","Ura","Urja","Urmi","Urmil","Urmila","Urmimala","Urna","Urshita","Urvashi","Urvasi",
    "Urvi","Usha","Ushakiran","Ushakiran","Ushashi","Ushma","Usri","Utpala","Utpalini","Utsa","Uttara","Vagdevi","Vahini","Vaidehi","Vaijayanti",
    "Vaijayantimala","Vaishali","Vaishali","Vaishavi","Vaishnodevi","Vajra","Vallari","Valli","Vallika","Vanadurga","Vanaja","Vanamala",
    "Vanani","Vandana","Vandana","Vanhi","Vanhishikha","Vani","Vanita","Vanmala","Varada","Varana","Vari","Varija","Varsha","Varuna",
    "Varuni","Varuni","Vasanta","Vasavi","Vasudha","Vasudhara","Vasumati","Vasundhara","Vatsala","Vedi","Vedika","Vedvalli","Veena",
    "Veenapani","Vela","Vetravati","Vibha","Vibhavari","Vibhuti","Vidhut","Vidula","Vidya","Vidyul","Vidyut","Vijaya","Vijayalakshmi",
    "Vijeta","Vijul","Vilasini","Vilina","Vimala","Vinanti","Vinata","Vinaya","Vindhya","Vineeta","Vinita","Vinoda","Vinodini","Vinodini",
    "Vipasa","Vipula","Virata","Visala","Vishakha","Vishala","Vishalakshi","Vishaya","Vishnumaya","Vishnupriya","Viveka","Vrajabala",
    "Vrinda","Vritti","Vrunda","Waheeda","Wamika","Wamil","Yaksha","Yamini","Yamuna","Yamuna","Yamune","Yashaswini","Yashawini","Yashila",
    "Yashoda","Yasmeen","Yasmin","Yasmina","Yasmine","Yatee","Yauvani","YaVonne","Yogini","Yogita","Yojana","Yuvati","Zahra","Zarine","Zeenat");
    my $random_string = $Indian_Female_Name[rand @Indian_Female_Name];
    return $random_string;
}


sub random_job_name{
    my @Jobs = ("general manager","assistant manager","manager","personnel manager","production manager","marketing manager",
    "sales manager","accounts manager","supervisor","inspector","office clerk","receptionist","secretary","typist","stenographer",
    "banker","bank officer","accountant","bookkeeper","economist","teller","cashier","auditor","sales representative",
    "sales manager","salesperson","salesman","salesclerk","cashier","engineer","technician","mechanic","builder",
    "construction worker","repairer","welder","bricklayer","mason","carpenter","plumber","painter","wholesaler",
    "retailer","distributor","advertising agent");
    my $random_string = $Jobs[rand @Jobs];
    return $random_string;
}


sub random_country_name{
    my @Country = ("Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", 
    "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", 
    "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Côte d'Ivoire", "Cabo Verde", 
    "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", 
    "Congo (Congo-Brazzaville)", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia (Czech Republic)", "Democratic Republic of the Congo", 
    "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", 
    "Estonia", "Swaziland", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", 
    "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hungary", 
    "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", 
    "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", 
    "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", 
    "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar (formerly Burma)", 
    "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", 
    "Norway", "Oman", "Pakistan", "Palau", "Palestine State", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", 
    "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", 
    "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", 
    "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", 
    "Suriname", "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", 
    "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States of America", 
    "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe");
    my $random_string = $Country[rand @Country];
    return $random_string;
}


# this will generate random numeric numbers with the given length
# ex: random_numeric_string(6); = "454546"
sub random_numeric_string{
    my $length_of_randomstring = shift;
    #print "length_of_randomstring : $length_of_randomstring\n";
    
    if ($length_of_randomstring == 0)
    {
      return 0;  
    }
    my @chars=('0'..'9');
    my $random_string;
    for(my $i = 0; $i < $length_of_randomstring; $i++)
    {
        $random_string .= $chars[int(rand @chars)];
    }
    return $random_string;
}

sub decimal_number{
    my ($pre,$dec_point) = @_;
    #print "before : pre, dec_point = $pre, $dec_point\n";
    # decimal(10,5)
    # 10 - 5 = 5
    $pre = $pre - $dec_point;
    #print "after : pre, dec_point = $pre, $dec_point\n";
    my $result = random_numeric_string($pre) . "." . random_numeric_string($dec_point) ;
    #print "result = $result\n";    
    return $result;
}


sub random_number{
    my ($min, $max) = @_;
    my $result = int( rand( $max-$min+1 ) ) + $min;
    return $result;
}

sub random_real_number{
    my ($min, $max) = @_;
    my $result = rand( $max-$min+1 ) + $min;
    return $result;
}

sub decimal_number1{
    my ($min, $max) = @_;
    my $result = rand( $max-$min+1 ) + $min;
    return $result;
}

sub random_date{
    my ($start_year, $start_end) = @_;

    unless ($start_year and $start_end)
    {
        $start_year=1981, $start_end=2023;
    }
    # here we have 13 elements on the array, 0 to 12,
    # so, we need to take only 1 to 12
    # if we don't have this dummy_month , then some time the result is invalid
    my @months = ('dummy_month', 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec');

    my $daysInMonth =  {"jan" => 31, "feb" => 28, "mar" => 31, "apr" => 30,
                        "may" => 31, "jun" => 30, "jul" => 31, "aug" => 31,
                        "sep" => 30, "oct" => 31, "nov" => 30, "dec" => 31};

    # get random year
    my $year = int( rand( $start_end - $start_year + 1 ) ) + $start_year;
    #print "year = $year\n";

    # Check for leap year - divisible by 4 but not divisible by 100, or divisible by 400
    if (((($year % 4) == 0) && (($year % 100) != 0)) || ($year % 400) == 0) {
      $daysInMonth->{'feb'} = 29;
    }

    # get random month between 1 to 12
    my $month = int( rand( 12 - 1 + 1 ) ) + 1;
    #print "month = $month\n";

    my $days = $daysInMonth->{$months[$month]};
    my $day = int( rand( $days-1+1 ) ) + 1;
    #print "day = $day\n";

    my $date = $year . "-" . $month . "-" . $day;
    return $date;
}


sub random_year{
    my ($start_year, $start_end) = @_;

    unless ($start_year and $start_end)
    {
        $start_year=1981, $start_end=2023;
    }

    # get random year
    my $year = int( rand( $start_end - $start_year + 1 ) ) + $start_year;
    return $year;
}


sub random_time{
    my $hh = int( rand(23)) + 1;
    my $mm = int( rand(59)) + 1;
    my $ss = int( rand(59)) + 1;

    my $time = $hh . ":" . $mm . ":" . $ss;
    return $time;
}


sub random_datetime{
    my $date = random_date();
    my $time = random_time();
    my $datetime = $date . " " . $time;
    return $datetime;
}

sub random_timestamp{
    my $date = random_date();
    my $time = random_time();

    my @Chars = ('1'..'9');
    my $Length = 6;
    my $Number = '';

    for (1..$Length) {
        $Number .= $Chars[int rand @Chars];
    }

    my $datetime = $date . " " . $time . "." . $Number;
    return $datetime;
}

sub display_filesize_str
{
    my $file = shift();

    my $size = (stat($file))[7] || die "stat($file): $!\n";

    if ($size > 1099511627776)  #   TiB: 1024 GiB
    {
        printf("data file size = %.2f TiB\n", $size / 1099511627776);
    }
    elsif ($size > 1073741824)  #   GiB: 1024 MiB
    {
        printf("data file size = %.2f GiB\n", $size / 1073741824);
    }
    elsif ($size > 1048576)     #   MiB: 1024 KiB
    {
        printf("data file size = %.2f MiB\n", $size / 1048576);
    }
    elsif ($size > 1024)        #   KiB: 1024 B
    {
        printf("data file size = %.2f KiB\n", $size / 1024);
    }
    else                        #   bytes
    {
        printf "data file size = $size bytes\n";
    }
}
