//Bosoaga Costin 332CC
public class Fish {
    public static void main(String[] args) {
        Shark shark = new Shark();
        
        Salmon salmon = new Salmon();
    }
}

public class Shark {
    private String name;
    private int age;

    public Shark() {
        this.name = "None";
        this.age = 0;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public int getAge() {
        return age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }


}

class Salmon {
    private String name;
    private int age;
    
    public Salmon() {
        this.name = "None";
        this.age = 0;
    }

    public int getAge() {
        return age;
    }

    public String getName() {
        return name;
    }
}
