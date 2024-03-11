# a demo for https://blog.dixitaditya.com/ethernaut-level-22-dex
class Test:
    balance_da = 100
    balance_db = 100

    da = 10
    db = 10

    def price(self, is_out_a, amount):
        if is_out_a:
            return int(amount * self.balance_da / self.balance_db)
        return int(amount * self.balance_db / self.balance_da)

    def swap(self, is_out_a, amount):
        print("is_out_a: ", is_out_a, "amount: ", amount)
        out = self.price(is_out_a, amount)
        if is_out_a:
            self.da += out
            self.db -= amount
            self.balance_da -= out
            self.balance_db += amount
        else:
            self.da -= amount
            self.db += out
            self.balance_da += amount
            self.balance_db -= out
        if self.da < 0 or self.db < 0 or self.balance_da < 0 or self.balance_db < 0:
            raise Exception("Error negative value!")


t = Test()
for i in range(10):
    in_a = t.da > 0
    out_a = not in_a
    amount_in = t.da if in_a else t.db
    amount_out = t.price(out_a, amount_in)
    balance = t.balance_db if in_a else t.balance_da

    if amount_out > balance:
        amount_in = int(balance / amount_out * amount_in)

    t.swap(out_a, amount_in)
    print("da: ", t.da, "db: ", t.db, "balance_da: ", t.balance_da, "balance_db: ", t.balance_db)

    if t.balance_da == 0 or t.balance_db == 0:
        print("Success")
        break
