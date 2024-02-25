//Bosoaga Costin 332CC
public class Bookshelf {
    public static void main(String[] args) {
        Book[] books = new Book[10];

        for (int i = 0; i < books.length; i++) {
            books[i] = new Book("Title " + i, "Author " + i, i);
        }

        for (Book book : books) {
            System.out.println("Title: " + book.getTitle() + ", Author: " + book.getAuthor());
        }
    }
}

class Book {
    private String title;
    private String author;
    private int pages;

    public Book(String title, String author, int pages) {
        this.title = title;
        this.author = author;
        this.pages = pages;
    }

    public void setTitle(final String title) {
        this.title = title;
    }

    public String getTitle() {
        return title;
    }

    public void setAuthor(final String author) {
        this.author = author;
    }

    public String getAuthor() {
        return author;
    }

    public void setPages(final int pages) {
        this.pages = pages;
    }


    public static void main(String[] args) {
        Book book1 = new Book("Title 1", "Author 1", 1);
        Book book2 = new Book("Title 2", "Author 2", 2);
    }
}