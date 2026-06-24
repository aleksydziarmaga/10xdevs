import type { SupabaseClient } from "@supabase/supabase-js";
import type { CreateExpenseInput, CreateMonthlyBudgetInput, ExpenseRow, MonthlyBudgetRow } from "@/types";

type DbClient = SupabaseClient;

export async function createMonthlyBudget(
  client: DbClient,
  input: CreateMonthlyBudgetInput,
): Promise<MonthlyBudgetRow> {
  const { data, error } = await client
    .from("monthly_budgets")
    .insert(input)
    .select(
      "id, wallet_id, template_id, period_year, period_month, monthly_income_amount, guideline_needs_pct, guideline_wants_pct, guideline_savings_pct, created_at, updated_at",
    )
    .single();

  if (error) {
    throw error;
  }

  return data;
}

export async function createExpense(client: DbClient, input: CreateExpenseInput): Promise<ExpenseRow> {
  const { data, error } = await client
    .from("expenses")
    .insert({
      wallet_id: input.wallet_id,
      monthly_budget_id: input.monthly_budget_id ?? null,
      category_id: input.category_id ?? null,
      expense_date: input.expense_date,
      amount: input.amount,
      description: input.description ?? null,
      category_name: input.category_name ?? null,
      category_type: input.category_type ?? null,
    })
    .select(
      "id, wallet_id, monthly_budget_id, category_id, expense_date, amount, description, category_name, category_type, created_at, updated_at",
    )
    .single();

  if (error) {
    throw error;
  }

  return data;
}
