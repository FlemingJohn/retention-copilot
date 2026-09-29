use role ACCOUNTADMIN;
use warehouse RETENTION_COPILOT_WH;

create or replace function RETENTION_COPILOT.GENERATOR.GENERATE_PERSON(SEED number)
returns object
language python
runtime_version = '3.11'
packages = ('faker')
handler = 'run'
as $$
def run(seed):
    import random
    from faker import Faker
    fake = Faker('en_IN')
    rng = random.Random(seed)

    CITIES = [
        ("Mumbai", "Maharashtra", "400"),
        ("Mumbai", "Maharashtra", "400"),
        ("Mumbai", "Maharashtra", "400"),
        ("Delhi", "Delhi", "110"),
        ("Delhi", "Delhi", "110"),
        ("Delhi", "Delhi", "110"),
        ("Bengaluru", "Karnataka", "560"),
        ("Bengaluru", "Karnataka", "560"),
        ("Bengaluru", "Karnataka", "560"),
        ("Hyderabad", "Telangana", "500"),
        ("Hyderabad", "Telangana", "500"),
        ("Chennai", "Tamil Nadu", "600"),
        ("Chennai", "Tamil Nadu", "600"),
        ("Kolkata", "West Bengal", "700"),
        ("Kolkata", "West Bengal", "700"),
        ("Pune", "Maharashtra", "411"),
        ("Pune", "Maharashtra", "411"),
        ("Ahmedabad", "Gujarat", "380"),
        ("Ahmedabad", "Gujarat", "380"),
        ("Jaipur", "Rajasthan", "302"),
        ("Jaipur", "Rajasthan", "302"),
        ("Lucknow", "Uttar Pradesh", "226"),
        ("Surat", "Gujarat", "395"),
        ("Kanpur", "Uttar Pradesh", "208"),
        ("Nagpur", "Maharashtra", "440"),
        ("Indore", "Madhya Pradesh", "452"),
        ("Thane", "Maharashtra", "400"),
        ("Bhopal", "Madhya Pradesh", "462"),
        ("Visakhapatnam", "Andhra Pradesh", "530"),
        ("Patna", "Bihar", "800"),
        ("Vadodara", "Gujarat", "390"),
        ("Ghaziabad", "Uttar Pradesh", "201"),
        ("Ludhiana", "Punjab", "141"),
        ("Agra", "Uttar Pradesh", "282"),
        ("Nashik", "Maharashtra", "422"),
        ("Ranchi", "Jharkhand", "834"),
        ("Coimbatore", "Tamil Nadu", "641"),
        ("Kochi", "Kerala", "682"),
        ("Thiruvananthapuram", "Kerala", "695"),
        ("Chandigarh", "Chandigarh", "160"),
        ("Guwahati", "Assam", "781"),
        ("Bhubaneswar", "Odisha", "751"),
        ("Dehradun", "Uttarakhand", "248"),
        ("Mysuru", "Karnataka", "570"),
        ("Jodhpur", "Rajasthan", "342"),
        ("Amritsar", "Punjab", "143"),
        ("Raipur", "Chhattisgarh", "492"),
        ("Varanasi", "Uttar Pradesh", "221"),
        ("Rajkot", "Gujarat", "360"),
        ("Noida", "Uttar Pradesh", "201"),
    ]

    FIRST_NAMES = [
        "Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh", "Ayaan",
        "Krishna", "Ishaan", "Shaurya", "Atharva", "Advait", "Arnav", "Dhruv", "Kabir",
        "Ananya", "Aadhya", "Diya", "Priya", "Meera", "Saanvi", "Aanya", "Isha",
        "Kavya", "Riya", "Nisha", "Pooja", "Neha", "Shruti", "Sneha", "Tanvi",
        "Rahul", "Amit", "Suresh", "Rajesh", "Vikram", "Rohan", "Nikhil", "Sachin",
        "Manoj", "Deepak", "Sanjay", "Kiran", "Ajay", "Rakesh", "Gaurav", "Pranav",
        "Sunita", "Rekha", "Anjali", "Swati", "Divya", "Pallavi", "Megha", "Jyoti",
        "Rohit", "Harsh", "Kunal", "Varun", "Akash", "Manish", "Tushar", "Abhishek",
        "Pankaj", "Sunil", "Ramesh", "Naveen", "Ashok", "Yogesh", "Arun", "Vijay",
        "Siddharth", "Aniket", "Omkar", "Tejas", "Lakshmi", "Geeta", "Seema", "Parvati",
    ]

    LAST_NAMES = [
        "Sharma", "Verma", "Gupta", "Singh", "Kumar", "Patel", "Reddy", "Nair",
        "Joshi", "Rao", "Iyer", "Menon", "Pillai", "Bhat", "Desai", "Shah",
        "Mehta", "Chauhan", "Yadav", "Pandey", "Mishra", "Tiwari", "Dubey", "Saxena",
        "Agarwal", "Jain", "Banerjee", "Chatterjee", "Mukherjee", "Das", "Ghosh", "Bose",
        "Sen", "Roy", "Patil", "Kulkarni", "Deshpande", "Shinde", "More", "Pawar",
        "Thakur", "Chowdhury", "Mohan", "Rajan", "Subramaniam", "Naidu", "Hegde", "Shetty",
        "Kapoor", "Malhotra", "Arora", "Khanna", "Bedi", "Gill", "Sandhu", "Dhillon",
        "Mahajan", "Sethi", "Sinha", "Prasad", "Choudhary", "Trivedi", "Bhatt", "Negi",
        "Kaur", "Chopra", "Bajaj", "Garg", "Goyal", "Mittal", "Tandon", "Lal",
        "Dalal", "Dutta", "Mitra", "Kar", "Saha", "Pal", "Mukherjee", "Chakraborty",
    ]

    city, state, pin_prefix = rng.choice(CITIES)
    pin_suffix = str(rng.randint(0, 999)).zfill(3)
    pincode = pin_prefix + pin_suffix

    first_name = rng.choice(FIRST_NAMES)
    last_name = rng.choice(LAST_NAMES)

    Faker.seed(seed)
    email = first_name.lower() + "." + last_name.lower() + "@" + fake.free_email_domain()
    phone = fake.phone_number()
    address_line = fake.street_address()

    return {
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "phone": phone,
        "address_line": address_line,
        "city": city,
        "state": state,
        "pincode": pincode,
    }
$$;
