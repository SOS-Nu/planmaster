public interface IWorker
{
    void Work();
}

public abstract class Employee : IWorker
{
    public string Name;

    public void CheckIn()
    {
        Console.WriteLine(Name + " checked in");
    }

    public abstract void Work();

    public virtual void Report()
    {
        Console.WriteLine(Name + " sends a basic report");
    }
}

public class Developer : Employee
{
    public override void Work()
    {
        Console.WriteLine(Name + " writes code");
    }

    public override void Report()
    {
        Console.WriteLine(Name + " sends technical report");
    }
}

public class Tester : Employee
{
    public override void Work()
    {
        Console.WriteLine(Name + " tests software");
    }
}
Developer dev = new Developer();
dev.Name = "John";
dev.CheckIn();
dev.Work();
dev.Report();
Tester tester = new Tester();
tester.Name = "Jane";
tester.CheckIn();
tester.Work();
tester.Report();
