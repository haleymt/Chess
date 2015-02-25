class Employee
  attr_reader :name, :title, :salary
  attr_accessor :boss

  def employees
    nil
  end

  def initialize(name, title, salary)
    @name = name
    @title = title
    @salary = salary
    @boss = nil
  end

  def bonus(mult)
    @salary * mult
  end
end

class Manager < Employee
  def initialize(name, title, salary, *employees)
    super(name, title, salary)
    @managed_employees = employees
    @managed_employees.each do |employee|
      employee.boss = self
    end
  end

  def employees
    @managed_employees
  end

  def bonus(mult)
    total_bonus = 0
    queue = @managed_employees.dup
    while current_employee = queue.shift
      total_bonus += current_employee.salary * mult
      queue += current_employee.employees if current_employee.employees
    end

    total_bonus
  end


end

shawna = Employee.new('shawna', 'ta', 12000)
david = Employee.new('david', 'ta', 10000)
darren = Manager.new('darren', 'ta Manager', 78000, shawna, david)
ned = Manager.new('ned', 'founder', 1_000_000, darren)

puts ned.bonus(5)
puts
puts darren.bonus(4)
puts
puts david.bonus(3)
puts
